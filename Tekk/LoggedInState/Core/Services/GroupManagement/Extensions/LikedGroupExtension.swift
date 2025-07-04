

//
//  LikedDrillsExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//

import Foundation
import SwiftKeychainWrapper

extension SessionGeneratorModel: LikedDrillsManagement {
    
    func toggleDrillLike(drillId: UUID, drill: DrillModel) {
        if likedDrillsGroup.drills.contains(drill) {
            likedDrillsGroup.drills.removeAll(where: { $0.id == drillId })
        } else {
            likedDrillsGroup.drills.append(drill)
        }
        
        // Toggle on backend
        Task {
            do {
                if let backendDrillId = drill.backendId {
                    let response = try await DrillGroupService.shared.toggleDrillLike(drillId: backendDrillId)
                    print("✅ Successfully toggled drill like on backend: \(response.message)")
                } else {
                    print("⚠️ No backend ID available for drill: \(drill.title)")
                }
            } catch {
                print("❌ Error toggling drill like on backend: \(error)")
            }
        }
    }
    
    func isDrillLiked(_ drill: DrillModel) -> Bool {
        return likedDrillsGroup.drills.contains(drill)
    }
    
    func checkDrillLikedStatus(drillId: Int) async -> Bool {
        do {
            return try await DrillGroupService.shared.checkDrillLiked(drillId: drillId)
        } catch {
            print("❌ Error checking drill liked status: \(error)")
            // Fall back to local state, using backendId if available
            return likedDrillsGroup.drills.contains(where: { $0.backendId == drillId })
        }
    }
    
    // Get or create a user-specific UUID for the liked drills group
    func getLikedDrillsUUID() -> UUID {
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "default"
        let key = "\(userEmail)_likedDrillsUUID"
        
        // Check if we already have a UUID stored for this user
        if let uuidString = UserDefaults.standard.string(forKey: key),
           let uuid = UUID(uuidString: uuidString) {
            print("📱 Using existing liked drills UUID for user: \(userEmail)")
            return uuid
        }
        
        // Generate a new UUID for this user
        let newUUID = UUID()
        UserDefaults.standard.set(newUUID.uuidString, forKey: key)
        print("📱 Generated new liked drills UUID for user: \(userEmail)")
        return newUUID
    }
    
    // Clear method to remove a user's likedDrillsUUID
    func clearLikedDrillsUUID() {
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "default"
        let key = "\(userEmail)_likedDrillsUUID"
        UserDefaults.standard.removeObject(forKey: key)
        print("🗑️ Cleared liked drills UUID for user: \(userEmail)")
    }
}
