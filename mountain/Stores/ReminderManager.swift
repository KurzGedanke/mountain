//
//  ReminderManager.swift
//  mountain
//
//  Schedules a local notification a few minutes before each favorited band
//  plays. Re-synced whenever favorites or the schedule change: it clears all
//  pending requests and re-adds only future sets for currently favorited bands.
//

import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class ReminderManager {
    /// Minutes before a set starts that the reminder fires.
    private let leadMinutes = 15

    private(set) var authorized = false

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        authorized = granted
    }

    /// Rebuilds all pending reminders from scratch. When `enabled` is false (the
    /// user turned reminders off in Settings) all pending reminders are cleared
    /// and nothing is scheduled.
    func sync(enabled: Bool, favorites: Set<Int>, slots: [TimeSlot]) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard enabled else { return }

        let settings = await center.notificationSettings()
        let allowed = settings.authorizationStatus == .authorized
            || settings.authorizationStatus == .provisional
        guard allowed else { return }

        let now = Date()
        let lead = TimeInterval(leadMinutes * 60)

        for slot in slots where favorites.contains(slot.bandId) {
            let fireDate = slot.start.addingTimeInterval(-lead)
            guard fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = slot.band
            content.body = String(localized: "On stage at \(slot.start.formatted(.dateTime.hour().minute())) · \(slot.stage)")
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: slot.id, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }
}
