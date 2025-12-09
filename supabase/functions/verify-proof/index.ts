// supabase/functions/verify-proof/index.ts

// This function:
// 1. Accepts JSON: { imagePath: string, goalTitle: string }
// 2. Builds a signed URL or uses the storage URL to get the image
// 3. Calls OpenAI Vision with a prompt about the goal
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

    // Get a signed URL for the image (valid for e.g. 5 minutes)
    const { data: signedData, error: signedError } = await supabase.storage
      .from("proof-images")
      .createSignedUrl(imagePath, 60 * 5);

    if (signedError || !signedData?.signedUrl) {
      return new Response(JSON.stringify({ error: "Could not get signed URL" }), {
        status: 500,
      });
    }

    const imageUrl = signedData.signedUrl;

    // Build prompt
    const prompt = `The user has a habit goal: "${goalTitle}".
You are verifying if the given image shows convincing evidence that the user is performing that habit.
Return a short explanation about whether the image matches the habit and how confident you are.`;

    // Call OpenAI vision
    const openAiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${openAiApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4-vision-preview",
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
      }),
    });

    if (!openAiResponse.ok) {
      const text = await openAiResponse.text();
      return new Response(JSON.stringify({ error: "OpenAI call failed", detail: text }), {
        status: 500,
      });
    }

    const openAiJson = await openAiResponse.json();

    // Parse the response
    const explanation = openAiJson.choices?.[0]?.message?.content ?? "No explanation available.";

    // Simple heuristic: if explanation contains "yes" or "looks like", mark as verified.
    const lower = explanation.toLowerCase();
    const verified = lower.includes("yes") || lower.includes("appears to") || lower.includes("shows");

    const score = verified ? 0.9 : 0.3; // simple placeholder

    return new Response(
      JSON.stringify({
        verified,
        score,
        reason: explanation,
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
