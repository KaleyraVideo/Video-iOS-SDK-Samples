// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

enum Strings {

    // MARK: - Generic

    enum Generic {

        static let confirm = NSLocalizedString("call_options.confirm_button", comment: "Accept")
    }

    // MARK: - Login

    enum Login {

        static let title = NSLocalizedString("login.title", comment: "Choose an user")
        static let searchPlaceholder = NSLocalizedString("login.search_placeholder", comment: "Search")

        enum Loading {
            static let title = NSLocalizedString("login.loading", comment: "Loading")
        }

        enum NoContent {
            static let title = NSLocalizedString("login.empty_title", comment: "Warning")
            static let subtitle = NSLocalizedString("login.empty_subtitle", comment: "User not found")
        }

        enum Alert {
            static let title = NSLocalizedString("login.error_title", comment: "An error has occurred")
            static let retryAction = NSLocalizedString("login.error_retry_action", comment: "Retry")
            static let cancelAction = NSLocalizedString("login.error_cancel", comment: "OK")
            static let exitAction = NSLocalizedString("login.error_exit", comment: "Exit")
        }
    }

    // MARK: - Setup

    enum AppSetupType {

        static let qr = NSLocalizedString("app_setup_type.qr", comment: "QR code")
        static let wizard = NSLocalizedString("app_setup_type.wizard", comment: "Step by step")
        static let advanced = NSLocalizedString("app_setup_type.advanced", comment: "Advanced")
    }

    enum Setup {

        static let title = NSLocalizedString("setup.title", comment: "Setup")

        static let confirm = NSLocalizedString("setup.accept_button", comment: "Accept")
        static let cancel = NSLocalizedString("setup.cancel_button", comment: "Cancel")

        enum EnvironmentSection {

            static let title = NSLocalizedString("setup.environment_section", comment: "Environment")

            static let production = NSLocalizedString("setup.environment_production", comment: "Production")
            static let sandbox = NSLocalizedString("setup.environment_sandbox", comment: "Sandbox")
            static let develop = NSLocalizedString("setup.environment_develop", comment: "Develop")
        }

        enum RegionSection {

            static let title = NSLocalizedString("setup.region_title", comment: "Region")

            static let europe = NSLocalizedString("setup.region_europe", comment: "Europe")
            static let india = NSLocalizedString("setup.region_india", comment: "India")
            static let us = NSLocalizedString("setup.region_us", comment: "US")
            static let middleEast = NSLocalizedString("setup.region_middle_east", comment: "Middle East")
        }

        enum CompanySection {
            static let sales = NSLocalizedString("setup.company.sales", comment: "Kaleyra Sales")
            static let video = NSLocalizedString("setup.company.video", comment: "Kaleyra Video")
        }

        enum AppIdSection {

            static let title = NSLocalizedString("setup.app_id", comment: "App id")
            static let footer = NSLocalizedString("setup.app_id.footer", comment: "")
        }

        enum ApiKeySection {

            static let title = NSLocalizedString("setup.rest_api_key", comment: "REST API Key")
            static let footer = NSLocalizedString("setup.rest_api_key.footer", comment: "")
        }

        enum UserDetailsSection {

            static let title = NSLocalizedString("setup.user_section", comment: "User details")

            static let cellTitle = NSLocalizedString("setup.show_user_details", comment: "Show user details")
        }

        enum VoIPSection {

            static let title = NSLocalizedString("setup.voip_section_title", comment: "VoIP")
            static let automatic = NSLocalizedString("setup.voip_automatic", comment: "Automatic")
            static let manual = NSLocalizedString("setup.voip_manual", comment: "Manual")
            static let disabled = NSLocalizedString("setup.voip_disabled", comment: "Disabled")
            static let notificationsInForeground = NSLocalizedString("setup.voip_notifications_in_foreground", comment: "Handle notifications in foreground")
            static let disableDirectIncomingCalls = NSLocalizedString("setup.voip_disable_direct_incoming_calls", comment: "Disable direct incoming calls")
        }

        enum InvalidConfigAlert {

            static let title = NSLocalizedString("setup.alert.title", comment: "Invalid Configuration")
            static let message = NSLocalizedString("setup.alert.message", comment: "The configuration provided is not valid...")
            static let cancelAction = NSLocalizedString("setup.alert.cancel-action.title", comment: "Ok")
        }
    }

    // MARK: - Contact

    enum Contacts {
        static let searchPlaceholder = NSLocalizedString("contacts.search_placeholder", comment: "Search")
        static let title = NSLocalizedString("contacts.title", comment: "Contacts")
        static let tabName = NSLocalizedString("contacts.tab", comment: "Contacts")

        enum Loading {
            static let title = NSLocalizedString("contacts.loading_title", comment: "Loading")
        }

        enum NoContent {
            static let title = NSLocalizedString("contacts.empty_title", comment: "Warning")
            static let subtitle = NSLocalizedString("contacts.empty_subtitle", comment: "There are no contacts available.")
        }

        enum Alert {
            static let title = NSLocalizedString("contacts.error_title", comment: "An error has occurred")
            static let retryAction = NSLocalizedString("contacts.error_action", comment: "Retry")
        }

        enum Actions {
            static let call = NSLocalizedString("contacts.cell.call_action", comment: "Call")
            static let video = NSLocalizedString("contacts.cell.video_call_action", comment: "Video")
            static let chat = NSLocalizedString("contacts.cell.chat_action", comment: "Chat")
        }
    }

    // MARK: - Contact update

    enum ContactUpdate {

        static let title = NSLocalizedString("contacts.update.title", comment: "Update user")
        static let nameSectionTitle = NSLocalizedString("contact_update.first_name", comment: "Name")
        static let lastnameSectionTitle = NSLocalizedString("contact_update.last_name", comment: "Lastname")
        static let imageSectionTitle = NSLocalizedString("contact_update.image_url", comment: "Profile image URL")
        static let confirm = NSLocalizedString("contact_update.accept_button", comment: "Accept")
        static let cancel = NSLocalizedString("contact_update.cancel_button", comment: "Cancel")
    }

    // MARK: - Call Settings

    enum CallSettings {

        static let title = NSLocalizedString("call_options.title", comment: "Call options")
        static let confirm = NSLocalizedString("call_options.confirm_button", comment: "Accept")

        enum CallTypeSection {
            static let title = NSLocalizedString("call_options.call_type_section_title", comment: "Call type")
            static let audioVideo = NSLocalizedString("call_options.call_type_audio_video", comment: "Audio Video")
            static let audioUpgradable = NSLocalizedString("call_options.call_type_audio_upgradable", comment: "Audio Upgradable")
            static let audioOnly = NSLocalizedString("call_options.call_type_audio_only", comment: "Audio Only")
        }

        enum RecordingSection {
            static let title = NSLocalizedString("call_options.recording_section_title", comment: "Recording")
            static let none = NSLocalizedString("call_options.recording_none", comment: "None")
            static let automatic = NSLocalizedString("call_options.recording_automatic", comment: "Automatic")
            static let manual = NSLocalizedString("call_options.recording_manual", comment: "Manual")
        }

        enum ButtonsSection {
            static let title = NSLocalizedString("call_options.buttons_section", comment: "Custom buttons")

            static let enableCellTitle = NSLocalizedString("call_options.buttons_enable_cell_title", comment: "Enable custom buttons")
            static let customizeCellTitle = NSLocalizedString("call_options.buttons_customize_cell_title", comment: "Customize buttons")
        }

        enum ToolsSection {

            static let title = NSLocalizedString("call_options.tools_section", comment: "Tools")

            static let chat = NSLocalizedString("call_options.tools-chat", comment: "Chat")
            static let whiteboard = NSLocalizedString("call_options.tools-whiteboard", comment: "Whiteboard")
            static let fileshare = NSLocalizedString("call_options.tools-fileshare", comment: "File share")
            static let screenshare = NSLocalizedString("call_options.tools-screenshare", comment: "In-app screen share")
            static let broadcast = NSLocalizedString("call_options.tools-broadcast", comment: "Broadcast screen share")
        }

        enum DurationSection {
            static let title = NSLocalizedString("call_options.call_duration", comment: "")
            static let duration = NSLocalizedString("call_options.call_duration", comment: "Call duration")
        }

        enum GroupSection {
            static let title = NSLocalizedString("call_options.group_call_section_title", comment: "Group options")
            static let conference = NSLocalizedString("call_options.call_type_group", comment: "Group call")
        }

        enum CameraSection {
            static let title = NSLocalizedString("call_options.camera_section_title", comment: "")
            static let front = NSLocalizedString("call_options.camera_section.front", comment: "")
            static let back = NSLocalizedString("call_options.camera_section.back", comment: "")
        }

        enum RatingSection {
            static let title = NSLocalizedString("call_options.rating_section_title", comment: "Rating")
            static let enabled = NSLocalizedString("call_options.rating_enabled", comment: "Enable rating")
        }

        enum PresentationMode {
            static let title = NSLocalizedString("call_options.call_presentation_mode_title", comment: "Call UI presentation mode")
            static let fullscreen = NSLocalizedString("call_options.call_presentation_mode_fullscreen", comment: "Fullscreen")
            static let pip = NSLocalizedString("call_options.call_presentation_mode_pip", comment: "Picture in picture")
        }

        enum SpeakerSection {

            static let title = NSLocalizedString("call_options.speaker_override_title", comment: "")
            static let always = NSLocalizedString("call_options.speaker_override_title.always", comment: "")
            static let video = NSLocalizedString("call_options.speaker_override_title.video", comment: "")
            static let videoInForeground = NSLocalizedString("call_options.speaker_override_title.videoForeground", comment: "")
            static let never = NSLocalizedString("call_options.speaker_override_title.never", comment: "")
        }
    }

    // MARK: - Settings

    enum Settings {

        static let title = NSLocalizedString("settings.title", comment: "Settings")
        static let tabName = NSLocalizedString("settings.tab", comment: "Settings")
        static let username = NSLocalizedString("settings.username", comment: "Username")
        static let environment = NSLocalizedString("settings.environment", comment: "Environment")
        static let region = NSLocalizedString("settings.region", comment: "Region")
        static let appVersion = NSLocalizedString("settings.app_version", comment: "App version")
        static let sdkVersion = NSLocalizedString("settings.sdk_version", comment: "SDK version")
        static let logout = NSLocalizedString("settings.logout", comment: "Logout")
        static let reset = NSLocalizedString("settings.reset", comment: "Reset")
        static let changeTheme = NSLocalizedString("settings.change_theme", comment: "Change theme")
        static let chooseTheme = NSLocalizedString("settings.choose.theme", comment: "Choose Theme")
        static let lightMode = NSLocalizedString("settings.light.mode", comment: "light mode")
        static let darkMode = NSLocalizedString("settings.dark.mode", comment: "dark mode")
        static let sandMode = NSLocalizedString("settings.sand.mode", comment: "sand mode")
        static let customMode = NSLocalizedString("settings.custom.mode", comment: "custom mode")
        static let customTheme = NSLocalizedString("settings.custom.theme", comment: "custom theme")
        static let cancelString = NSLocalizedString("settings.cancel", comment: "cancel string")
        static let selectFontString = NSLocalizedString("settings.select.font", comment: "select font")
    }

    // MARK: - QR Reader

    enum QRReader {

        static let cancelAction = NSLocalizedString("qr_reader.cancel_action", comment: "Cancel")

        enum Alert {

            static let title = NSLocalizedString("qr_reader.alert_title", comment: "An error has occurred!")
            static let message = NSLocalizedString("qr_reader.alert_message", comment: "An error has occurred while reading the QR code! Would you like to retry?")
            static let okAction = NSLocalizedString("qr_reader.retry_action", comment: "OK")
        }
    }

    // MARK: - Access link

    enum AccessLink {

        static let title = NSLocalizedString("access_link.title", comment: "Access link")
        static let message = NSLocalizedString("access_link.message", comment: "")
    }

    // MARK: - Logs

    enum Logs {

        enum Shortcut {

            static let title = NSLocalizedString("logs.shortcut.title", comment: "Share log files")
        }

        enum Alert {

            static let title = NSLocalizedString("logs.alert.title", comment: "Error sharing logs")
            static let noLogsMessage = NSLocalizedString("logs.alert.noLogsMessage", comment: "There is no log file present")
            static let sharingFailedMessage = NSLocalizedString("logs.alert.sharingFailedMessage", comment: "An error occurred while sharing log files")
            static let cancel = NSLocalizedString("logs.alert.cancel", comment: "Close")
        }

        enum Mail {

            static let recipient = "eu.video.engineering@kaleyra.com"
            static let subject = NSLocalizedString("logs.mail.subject", comment: "Sharing log files")
            static let body = NSLocalizedString("logs.mail.body", comment: "Please take a look at log files attached to this email.")
        }
    }
}
