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
        static let loadingTitle = NSLocalizedString("login.loading", comment: "Loading")
        static let emptyTitle = NSLocalizedString("login.empty_title", comment: "Warning")
        static let emptySubtitle = NSLocalizedString("login.empty_subtitle", comment: "User not found")

        enum ErrorAlert {
            static let title = NSLocalizedString("login.error_title", comment: "An error has occurred")
            static let retryAction = NSLocalizedString("login.error_retry_action", comment: "Retry")
            static let cancelAction = NSLocalizedString("login.error_cancel", comment: "OK")
            static let exitAction = NSLocalizedString("login.error_exit", comment: "Exit")
        }

        enum SaveErrorAlert {
            static let title = NSLocalizedString("login.alert_title", comment: "Warning")
            static let message = NSLocalizedString("login.alert_message", comment: "Could not save settings because of an error!")
            static let action = NSLocalizedString("login.alert_action", comment: "OK")
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

        enum ToolsSection {

            static let title = NSLocalizedString("setup.tools_section", comment: "Tools")

            static let chat = NSLocalizedString("setup.tools-chat", comment: "Chat")
            static let whiteboard = NSLocalizedString("setup.tools-whiteboard", comment: "Whiteboard")
            static let fileshare = NSLocalizedString("setup.tools-fileshare", comment: "File share")
            static let screenshare = NSLocalizedString("setup.tools-screenshare", comment: "In-app screen share")
            static let broadcast = NSLocalizedString("setup.tools-broadcast", comment: "Broadcast screen share")
        }

        enum CameraSection {
            static let title = NSLocalizedString("setup.camera_section", comment: "Camera")

            static let cameraFront = NSLocalizedString("setup.camera_front", comment: "Front camera")
            static let cameraBack = NSLocalizedString("setup.camera_back", comment: "Back camera")
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

        static let loadingTitle = NSLocalizedString("contacts.loading_title", comment: "Loading")
        static let emptyTitle = NSLocalizedString("contacts.empty_title", comment: "Warning")
        static let emptySubtitle = NSLocalizedString("contacts.empty_subtitle", comment: "There are no contacts available.")

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

        enum CallOptionsSection {

            static let title = NSLocalizedString("call_options.other_options_section", comment: "Other Options")
            static let duration = NSLocalizedString("call_options.call_duration", comment: "Call duration")
        }

        enum GroupSection {

            static let title = NSLocalizedString("call_options.group_call_section_title", comment: "Group options")
            static let conference = NSLocalizedString("call_options.call_type_group", comment: "Group call")
        }

        enum RatingSection {

            static let title = NSLocalizedString("call_options.rating_section_title", comment: "Rating")
            static let enabled = NSLocalizedString("call_options.rating_enabled", comment: "Enable rating")
        }

        enum CallPresentationMode {
            static let title = NSLocalizedString("call_options.call_presentation_mode_title", comment: "Call UI presentation mode")
            static let fullscreen = NSLocalizedString("call_options.call_presentation_mode_fullscreen", comment: "Fullscreen")
            static let pip = NSLocalizedString("call_options.call_presentation_mode_pip", comment: "Picture in picture")
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

        enum RestartAlert {

            static let title = NSLocalizedString("settings.restart-alert.title", comment: "Restart required")
            static let message = NSLocalizedString("settings.restart-alert.message", comment: "You are required to restart the app in order to apply these changes")
            static let actionTitle = NSLocalizedString("settings.restart-alert.action", comment: "OK")
        }
    }

    // MARK: - Color picker

    enum ColorPicker {

        static let title = NSLocalizedString("color_picker.title", comment: "Colors")
        static let grid = NSLocalizedString("color_picker.grid", comment: "Grid")
        static let cursors = NSLocalizedString("color_picker.cursors", comment: "Cursors")
        static let red = NSLocalizedString("color_picker.red", comment: "Red")
        static let green = NSLocalizedString("color_picker.green", comment: "Red")
        static let blue = NSLocalizedString("color_picker.blue", comment: "Red")
        static let opacity = NSLocalizedString("color_picker.opacity", comment: "Red")

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

    // MARK: - User verification

    enum UserVerification {

        static let reason = NSLocalizedString("user_verification.reason", comment: "Authentication required!")
    }

    // MARK: - Access link

    enum AccessLink {

        static let title = NSLocalizedString("access_link.title", comment: "Access link")
        static let message = NSLocalizedString("access_link.message", comment: "")
    }

    // MARK: - Logs

    enum Debug {

        enum Logs {

            static let shareLogFiles = NSLocalizedString("debug.logs.share_log_files", comment: "Share log files")

            enum Alert {

                static let shareLogErrorTitle = NSLocalizedString("debug.logs.share_log_error_title", comment: "Error sharing logs")
                static let noLogFilePresentError = NSLocalizedString("debug.logs.no_log_file_present_error", comment: "There is no log file present")
                static let unableToShareLogError = NSLocalizedString("debug.logs.unable_to_share_log_error", comment: "An error occurred while sharing log files")
                static let shareLogErrorCancel = NSLocalizedString("debug.logs.share_log_error_cancel", comment: "Close")
            }

            enum Mail {

                static let shareLogMailSubject = NSLocalizedString("debug.logs.share_log_mail_subject", comment: "Sharing log files")
                static let shareLogMailBody = NSLocalizedString("debug.logs.share_log_mail_body", comment: "Please take a look at log files attached to this email.")
            }
        }
    }
}
