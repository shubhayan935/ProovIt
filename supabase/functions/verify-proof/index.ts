// This function:
// 1. Accepts JSON: { imagePath: string, goalTitle: string }
// 2. Creates a signed URL from the storage bucket to access the image
// 3. Calls OpenAI Vision API with a prompt about the goal
// 4. Returns { verified: boolean, score: number, reason: string }

import { serve } from "https://deno.land/std@0.181.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const openAiApiKey = Deno.env.get("OPENAI_API_KEY") ?? "";

const supabase = createClient(supabaseUrl, supabaseKey);

serve(async (req) => {
  try {
    const { imagePath, goalTitle } = await req.json();

    if (!imagePath || !goalTitle) {
      return new Response(JSON.stringify({ error: "Missing imagePath or goalTitle" }), {
        status: 400,
      });
    }

    // Get a signed URL for the image (valid for 5 minutes)
    const { data: signedData, error: signedError } = await supabase.storage
      .from("proof-images")
      .createSignedUrl(imagePath, 60 * 5);

    if (signedError || !signedData?.signedUrl) {
      return new Response(JSON.stringify({ error: "Could not get signed URL" }), {
        status: 500,
      });
    }

    const imageUrl = signedData.signedUrl;

    const prompt = `You are verifying if an image shows evidence of completing a habit goal.

Goal: "${goalTitle}"

Analyze the image and determine if it provides convincing proof that the user completed this goal.

Respond ONLY with valid JSON in this exact format:
{
  "verified": true or false,
  "confidence": 0.0 to 1.0,
  "reasoning": "Brief explanation of your decision (1-2 sentences)"
}

Be strict but fair. The image should clearly show the habit being performed or completed.`;

    const openAiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${openAiApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: prompt },
              { type: "image_url", image_url: { url: imageUrl } },
            ],
          },
        ],
        max_tokens: 300,
        temperature: 0.3,
      }),
    });

    if (!openAiResponse.ok) {
      const text = await openAiResponse.text();
      return new Response(JSON.stringify({ error: "OpenAI call failed", detail: text }), {
        status: 500,
      });
    }

    const openAiJson = await openAiResponse.json();
    let responseText = openAiJson.choices?.[0]?.message?.content ?? "{}";

    // Strip markdown code blocks if present (```json ... ```)
    responseText = responseText.replace(/```json\s*/g, "").replace(/```\s*/g, "").trim();

    // Parse the JSON response from OpenAI
    let aiDecision;
    try {
      aiDecision = JSON.parse(responseText);
    } catch (parseError) {
      console.error("Failed to parse AI response:", responseText);
      const lower = responseText.toLowerCase();
      aiDecision = {
        verified: lower.includes("yes") || lower.includes("verified") || lower.includes("correct"),
        confidence: 0.5,
        reasoning: responseText || "Unable to verify the image clearly.",
      };
    }

    const verified = aiDecision.verified === true;
    const score = aiDecision.confidence || (verified ? 0.9 : 0.3);
    const reason = aiDecision.reasoning || "No explanation provided.";

    return new Response(
      JSON.stringify({
        verified,
        score,
        reason,
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ error: "Unexpected error" }), { status: 500 });
  }
});
