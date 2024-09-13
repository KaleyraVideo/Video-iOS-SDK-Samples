// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class CallSettingsTests: UnitTestCase {

    func testDefaultInitialiserSetupObjectWithDefaultValue() {
        let sut = CallSettings()

        assertThat(sut.type, equalTo(.audioVideo))
        assertThat(sut.maximumDuration, equalTo(0))
        assertThat(sut.recording, equalTo(.none))
        assertThat(sut.isGroup, isFalse())
        assertThat(sut.showsRating, isFalse())
        assertThat(sut.presentationMode, equalTo(.fullscreen))
        assertThat(sut.cameraPosition, equalTo(.front))
    }

    // MARK: - Decodable

    func testDecodesValue() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "group" : true,
            "rating" : true,
            "presentationMode" : "pip",
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenCallTypeIsMissing() throws {
        let json = """
        {
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "group" : true,
            "rating" : true,
            "presentationMode" : "pip",
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenRecordingIsMissing() throws {
        let json = """
        {
            "type" : "audio upgradable",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "group" : true,
            "rating" : true,
            "presentationMode" : "pip",
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioUpgradable))
        assertThat(decoded.recording, nilValue())
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenToolsIsMissing() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "duration" : 42,
            "group" : true,
            "rating" : true,
            "presentationMode" : "pip",
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenDurationIsMissing() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "group" : true,
            "rating" : true,
            "presentationMode" : "pip",
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(0))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenGroupIsMissing() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "rating" : true,
            "presentationMode" : "pip",
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isFalse())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenRatingIsMissing() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "group" : true,
            "presentationMode" : "pip",
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isFalse())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenPresentationModeIsMissing() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "group" : true,
            "rating" : true,
            "camera" : "front",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.fullscreen))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenCameraIsMissing() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "group" : true,
            "rating" : true,
            "presentationMode" : "pip",
            "speaker" : "always"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.always))
    }

    func testDecodesValueWhenSpeakerIsMissing() throws {
        let json = """
        {
            "type" : "audio video",
            "recording" : "automatic",
            "tools" : {
                "isChatEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isFileshareEnabled" : true,
                "isScreenshareEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "duration" : 42,
            "group" : true,
            "rating" : true,
            "presentationMode" : "pip",
            "camera" : "front"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.type, equalTo(.audioVideo))
        assertThat(decoded.recording, equalTo(.automatic))
        assertThat(decoded.tools, equalTo(.default))
        assertThat(decoded.maximumDuration, equalTo(42))
        assertThat(decoded.isGroup, isTrue())
        assertThat(decoded.showsRating, isTrue())
        assertThat(decoded.presentationMode, equalTo(.pip))
        assertThat(decoded.cameraPosition, equalTo(.front))
        assertThat(decoded.speakerOverride, equalTo(.default))
    }

    // MARK: - Helpers

    private func decode(_ json: String) throws -> CallSettings {
        try JSONDecoder().decode(CallSettings.self, from: Data(json.utf8))
    }
}
