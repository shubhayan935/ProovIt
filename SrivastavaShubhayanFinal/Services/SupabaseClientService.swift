//
//  SupabaseClientService.swift
//  SrivastavaShubhayanFinal
//
//  Service - Supabase Client
//
//  Supabase Client Service
//  Environment variables required in Edit Scheme → Run → Environment Variables:
//     - SUPABASE_URL: your_project_url
//     - SUPABASE_ANON_KEY: your_anon_key
//

import Foundation
import Supabase

final class SupabaseClientService {
    static let shared = SupabaseClientService()

    let client: SupabaseClient

    private init() {
        // Use Xcode scheme env variables
        let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
        let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""

        guard let url = URL(string: urlString), !key.isEmpty else {
            fatalError("SUPABASE_URL or SUPABASE_ANON_KEY not configured in Xcode scheme environment variables")
        }

        // Configure auth options to suppress session warning (we use Twilio, not Supabase Auth)
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: .init(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )

        
    }
}
