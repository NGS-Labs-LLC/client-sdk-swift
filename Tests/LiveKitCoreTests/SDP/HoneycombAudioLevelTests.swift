/*
 * Copyright 2026 LiveKit
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// honeycomb: the audio-level header extensions are never negotiated (D82, hive-node 6.6).

@testable import LiveKit
import Testing

@Suite(.tags(.media))
struct HoneycombAudioLevelTests {
    private static let answer = """
    v=0
    o=- 0 0 IN IP4 127.0.0.1
    s=-
    t=0 0
    m=audio 9 UDP/TLS/RTP/SAVPF 111
    a=mid:0
    a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
    a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
    a=extmap:3/sendrecv urn:ietf:params:rtp-hdrext:csrc-audio-level
    a=rtpmap:111 opus/48000/2
    m=video 9 UDP/TLS/RTP/SAVPF 96
    a=mid:1
    a=extmap:4 urn:ietf:params:rtp-hdrext:toffset
    a=rtpmap:96 VP8/90000
    """.replacingOccurrences(of: "\n", with: "\r\n") + "\r\n"

    @Test func removesBothAudioLevelExtensionsAndNothingElse() {
        let stripped = Transport.honeycombStripAudioLevel(Self.answer)
        #expect(!stripped.contains("audio-level"))
        #expect(stripped.contains("a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\r\n"))
        #expect(stripped.contains("a=extmap:4 urn:ietf:params:rtp-hdrext:toffset\r\n"))
        #expect(stripped == Self.answer
            .replacingOccurrences(of: "a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\n", with: "")
            .replacingOccurrences(of: "a=extmap:3/sendrecv urn:ietf:params:rtp-hdrext:csrc-audio-level\r\n", with: ""))
    }

    @Test func leavesADescriptionWithoutThemByteForByte() {
        let clean = Transport.honeycombStripAudioLevel(Self.answer)
        #expect(Transport.honeycombStripAudioLevel(clean) == clean)
    }
}
