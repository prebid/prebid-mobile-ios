/*   Copyright 2018-2025 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

@_spi(PBMInternal) @testable import PrebidMobile

/// The inputs of the VAST parser parity test: every VAST XML fixture used by the VAST tests, plus synthetic documents
/// that reach parser branches the fixtures do not (icons, non-linear/companion resources, wrapper attributes,
/// character-data accumulation, malformed XML, unknown elements, the early returns that leak the element path).
enum VastParserParityCases {

    /// Case name -> VAST document. File cases are named after the sample file, synthetic ones start with `synthetic_`.
    static func allCases() -> [(name: String, data: Data?)] {
        var cases = [(name: String, data: Data?)]()

        for fileName in fixtureFileNames {
            cases.append((fileName, UtilitiesForTesting.loadFileAsDataFromBundle(fileName)))
        }
        for (name, xml) in syntheticDocuments {
            cases.append((name, Data(xml.utf8)))
        }
        cases.append(("synthetic_empty_data", Data()))
        cases.append(("synthetic_not_xml", Data("this is not xml".utf8)))

        return cases
    }

    static let fixtureFileNames = [
        "vast.3.0.xml",
        "VAST_with_companion.xml",
        "VAST_with_empty_companion.xml",
        "VAST_Empty_Inline.xml",
        "VAST_Empty_Response.xml",
        "VAST_Empty_Response2.xml",
        "document_with_one_inline_ad.xml",
        "document_with_one_wrapper_ad.xml",
        "inline_with_padding_on_urls.xml",
        "prebid_vast_response.xml",
        "vast_om_verification_from_extension.xml",
        "vast_om_verification_one_inline_ad.xml"
    ]

    static let syntheticDocuments: [(String, String)] = [
        // Linear creative with every attribute and child the parser reads: icons (all three resource kinds and the
        // three icon click elements), media files, skipoffset, tracking incl. progress offsets, ad parameters.
        ("synthetic_linear_icons_media", """
        <VAST version="4.1">
          <Ad id="ad-1" sequence="3">
            <InLine>
              <AdSystem version="2.5">Sys</AdSystem>
              <AdTitle>Title</AdTitle>
              <Advertiser>Adv</Advertiser>
              <Impression><![CDATA[ http://imp/1 ]]></Impression>
              <Error><![CDATA[http://err/1]]></Error>
              <Creatives>
                <Creative id="cr-1" AdID="adid-1" sequence="7">
                  <Linear skipoffset="00:00:05">
                    <Duration>01:02:03.5</Duration>
                    <AdParameters><![CDATA[a=b]]></AdParameters>
                    <TrackingEvents>
                      <Tracking event="start"><![CDATA[http://t/start]]></Tracking>
                      <Tracking event="progress" offset="5"><![CDATA[http://t/progress5]]></Tracking>
                      <Tracking event="progress"><![CDATA[http://t/progressNone]]></Tracking>
                      <Tracking event="complete">http://t/complete-plain</Tracking>
                    </TrackingEvents>
                    <VideoClicks>
                      <ClickThrough><![CDATA[http://click/through]]></ClickThrough>
                      <ClickTracking><![CDATA[http://click/track1]]></ClickTracking>
                      <CustomClick><![CDATA[http://click/custom1]]></CustomClick>
                    </VideoClicks>
                    <Icons>
                      <Icon program="AdChoices" width="20" height="30" xPosition="1" yPosition="2" duration="00:00:10" startOffset="00:00:01">
                        <StaticResource creativeType="image/png"><![CDATA[http://icon/static.png]]></StaticResource>
                        <IconClicks>
                          <IconClickThrough><![CDATA[http://icon/through]]></IconClickThrough>
                          <IconClickTracking><![CDATA[http://icon/track1]]></IconClickTracking>
                          <IconClickTracking><![CDATA[http://icon/track2]]></IconClickTracking>
                        </IconClicks>
                        <IconViewTracking><![CDATA[http://icon/view]]></IconViewTracking>
                      </Icon>
                      <Icon>
                        <IFrameResource><![CDATA[http://icon/frame]]></IFrameResource>
                      </Icon>
                      <Icon program="html" width="x" height="3.9">
                        <HTMLResource><![CDATA[<b>icon</b>]]></HTMLResource>
                      </Icon>
                    </Icons>
                    <MediaFiles>
                      <MediaFile id="m1" delivery="streaming" type="video/mp4" width="640" height="360" codec="h264" apiFramework="VPAID" bitrate="500.5" minBitrate="100" maxBitrate="900" scalable="true" maintainAspectRatio="false">
                        <![CDATA[ http://media/1.mp4 ]]>
                      </MediaFile>
                      <MediaFile delivery="progressive" width="abc" bitrate="x" scalable="TRUE">
                        <![CDATA[http://media/2.mp4]]>
                      </MediaFile>
                      <MediaFile/>
                    </MediaFiles>
                  </Linear>
                </Creative>
              </Creatives>
            </InLine>
          </Ad>
        </VAST>
        """),

        // CompanionAds (required mode, three resource kinds, click elements, tracking) and NonLinearAds
        // (attributes, resources, click elements, tracking before any NonLinear, resource without a NonLinear).
        ("synthetic_companion_nonlinear", """
        <VAST version="3.0">
          <Ad id="ad-2">
            <InLine>
              <AdSystem>Sys</AdSystem>
              <Creatives>
                <Creative id="c-companion">
                  <CompanionAds required="all">
                    <Companion id="comp-1" width="300" height="250" assetWidth="299" assetHeight="249">
                      <StaticResource creativeType="image/jpeg"><![CDATA[http://comp/1.jpg]]></StaticResource>
                      <AdParameters><![CDATA[comp=params]]></AdParameters>
                      <TrackingEvents>
                        <Tracking event="creativeView"><![CDATA[http://comp/view]]></Tracking>
                      </TrackingEvents>
                      <CompanionClickThrough><![CDATA[http://comp/through]]></CompanionClickThrough>
                      <CompanionClickTracking><![CDATA[http://comp/track1]]></CompanionClickTracking>
                      <CompanionClickTracking><![CDATA[http://comp/track2]]></CompanionClickTracking>
                    </Companion>
                    <Companion width="1" height="2">
                      <IFrameResource><![CDATA[http://comp/frame]]></IFrameResource>
                    </Companion>
                    <Companion>
                      <HTMLResource><![CDATA[<i>comp</i>]]></HTMLResource>
                    </Companion>
                    <CompanionClickThrough>http://comp/after-last</CompanionClickThrough>
                  </CompanionAds>
                </Creative>
                <Creative id="c-companion-empty">
                  <CompanionAds>
                    <TrackingEvents>
                      <Tracking event="creativeView"><![CDATA[http://comp/no-companion]]></Tracking>
                    </TrackingEvents>
                  </CompanionAds>
                </Creative>
                <Creative id="c-nonlinear" sequence="0">
                  <NonLinearAds>
                    <TrackingEvents>
                      <Tracking event="creativeView"><![CDATA[http://nl/before-any-nonlinear]]></Tracking>
                    </TrackingEvents>
                    <StaticResource creativeType="image/gif"><![CDATA[http://nl/orphan-resource]]></StaticResource>
                    <NonLinearClickThrough><![CDATA[http://nl/orphan-through]]></NonLinearClickThrough>
                    <NonLinearClickTracking><![CDATA[http://nl/orphan-track]]></NonLinearClickTracking>
                    <NonLinear id="nl-1" width="320" height="50" assetWidth="319" assetHeight="49" scalable="true" maintainAspectRatio="true" minSuggestedDuration="00:00:10" apiFramework="VPAID">
                      <StaticResource creativeType="image/png"><![CDATA[http://nl/1.png]]></StaticResource>
                      <NonLinearClickThrough><![CDATA[http://nl/through]]></NonLinearClickThrough>
                      <NonLinearClickTracking><![CDATA[http://nl/track1]]></NonLinearClickTracking>
                    </NonLinear>
                    <TrackingEvents>
                      <Tracking event="creativeView"><![CDATA[http://nl/after-nonlinear]]></Tracking>
                    </TrackingEvents>
                    <NonLinear>
                      <HTMLResource><![CDATA[<u>nl</u>]]></HTMLResource>
                    </NonLinear>
                  </NonLinearAds>
                </Creative>
              </Creatives>
            </InLine>
          </Ad>
        </VAST>
        """),

        // Wrapper attributes, VASTAdTagURI, creative and ad sequence handling (zero, non-numeric, partial numeric).
        ("synthetic_wrapper_sequences", """
        <VAST version="3.0">
          <Ad id="w-1" sequence="abc">
            <Wrapper followAdditionalWrappers="false" allowMultipleAds="true" fallbackOnNoAd="true">
              <AdSystem version="9">WrapSys</AdSystem>
              <VASTAdTagURI><![CDATA[ http://wrapped/vast ]]></VASTAdTagURI>
              <Impression>http://wrap/imp</Impression>
              <Error>http://wrap/err</Error>
              <AdTitle>ignored for wrapper</AdTitle>
              <Creatives>
                <Creative id="wc-1" AdID="wa" sequence="12abc">
                  <Linear>
                    <TrackingEvents><Tracking event="start">http://wrap/start</Tracking></TrackingEvents>
                    <VideoClicks><ClickTracking>http://wrap/click</ClickTracking></VideoClicks>
                  </Linear>
                </Creative>
                <Creative sequence="0"><Linear/></Creative>
              </Creatives>
            </Wrapper>
          </Ad>
          <Ad id="w-2" sequence="0">
            <Wrapper followAdditionalWrappers="yes" allowMultipleAds="" fallbackOnNoAd="false">
              <VASTAdTagURI>http://wrapped/two</VASTAdTagURI>
            </Wrapper>
          </Ad>
          <Ad sequence="2">
            <Wrapper/>
          </Ad>
        </VAST>
        """),

        // Character data: entity references split foundCharacters into chunks that are trimmed one by one, CDATA is
        // trimmed, text and CDATA mix, a child element resets the parent's content.
        ("synthetic_text_handling", """
        <VAST version="3.0">
          <Ad id="t-1">
            <InLine>
              <AdSystem>   spaced   </AdSystem>
              <AdTitle>A &amp; B &lt;c&gt; &#65;</AdTitle>
              <Advertiser>  one <![CDATA[  two  ]]> three  </Advertiser>
              <Impression>
                 <![CDATA[
                    http://imp/multi-line
                 ]]>
              </Impression>
              <Impression></Impression>
              <Impression/>
              <Creatives>
                <Creative>
                  <Linear>
                    <AdParameters>pre<b>x</b>post</AdParameters>
                    <Duration>  00:00:07  </Duration>
                  </Linear>
                </Creative>
              </Creatives>
            </InLine>
          </Ad>
        </VAST>
        """),

        // Elements outside their parents: a Tracking without an event (returns without popping the element path),
        // a Companion/NonLinear/Icon/MediaFile with the wrong or no creative, Error elements at several depths,
        // an Ad with neither InLine nor Wrapper, unknown elements, an empty Creative.
        ("synthetic_misplaced_and_unknown", """
        <VAST version="2.0">
          <Error>http://top/error</Error>
          <Unknown a="1"><Nested>text</Nested></Unknown>
          <Ad id="m-1">
            <Error>http://ad/error-no-ad-object</Error>
          </Ad>
          <Ad id="m-2">
            <InLine>
              <AdSystem>Sys</AdSystem>
              <Extensions><Extension type="x"><Custom>y</Custom></Extension></Extensions>
              <Error>http://inline/error</Error>
              <Creatives>
                <Creative id="empty-creative"/>
                <Creative id="no-event">
                  <Linear>
                    <TrackingEvents>
                      <Tracking>http://no-event</Tracking>
                    </TrackingEvents>
                    <Icons><Icon><StaticResource creativeType="t">http://leaked-path-icon</StaticResource></Icon></Icons>
                    <MediaFiles><MediaFile type="video/mp4"><![CDATA[http://leaked-path-media]]></MediaFile></MediaFiles>
                  </Linear>
                </Creative>
                <Creative id="orphan-elements">
                  <Companion id="orphan-companion" width="1" height="1"/>
                  <NonLinear id="orphan-nonlinear"/>
                  <Icon program="orphan"/>
                  <MediaFile type="video/mp4"/>
                  <ClickThrough>http://orphan/through</ClickThrough>
                  <Duration>00:00:09</Duration>
                  <ClickTracking>http://orphan/click</ClickTracking>
                  <CustomClick>http://orphan/custom</CustomClick>
                  <IconClickThrough>http://orphan/icon-through</IconClickThrough>
                  <IconClickTracking>http://orphan/icon-track</IconClickTracking>
                  <IconViewTracking>http://orphan/icon-view</IconViewTracking>
                  <CompanionClickThrough>http://orphan/comp-through</CompanionClickThrough>
                  <CompanionClickTracking>http://orphan/comp-track</CompanionClickTracking>
                  <NonLinearClickThrough>http://orphan/nl-through</NonLinearClickThrough>
                  <NonLinearClickTracking>http://orphan/nl-track</NonLinearClickTracking>
                  <StaticResource>http://orphan/static</StaticResource>
                  <Tracking event="start">http://orphan/tracking</Tracking>
                </Creative>
              </Creatives>
            </InLine>
          </Ad>
        </VAST>
        """),

        // Verification: resources with and without tracking, JavaScriptResource attributes, parameters, and a
        // Verification outside AdVerifications (dropped), and AdVerifications inside a Wrapper (dropped).
        ("synthetic_verifications", """
        <VAST version="4.0">
          <Ad id="v-1">
            <InLine>
              <AdSystem>Sys</AdSystem>
              <Extensions>
                <Extension type="AdVerifications">
                  <AdVerifications>
                    <Verification vendor="vendor-a">
                      <JavaScriptResource apiFramework="omid" browserOptional="true"><![CDATA[http://verif/a.js]]></JavaScriptResource>
                      <ExecutableResource><![CDATA[http://verif/exec]]></ExecutableResource>
                      <TrackingEvents>
                        <Tracking event="verificationNotExecuted"><![CDATA[http://verif/not-executed]]></Tracking>
                        <Tracking event="verificationNotExecuted"><![CDATA[http://verif/not-executed-2]]></Tracking>
                      </TrackingEvents>
                      <VerificationParameters><![CDATA[ {"k":"v"} ]]></VerificationParameters>
                    </Verification>
                    <Verification>
                      <JavaScriptResource><![CDATA[http://verif/b.js]]></JavaScriptResource>
                    </Verification>
                  </AdVerifications>
                  <Verification vendor="outside"><JavaScriptResource>http://verif/outside.js</JavaScriptResource></Verification>
                </Extension>
              </Extensions>
            </InLine>
          </Ad>
          <Ad id="v-2">
            <Wrapper>
              <VASTAdTagURI>http://wrapped/verif</VASTAdTagURI>
              <Extensions>
                <Extension type="AdVerifications">
                  <AdVerifications>
                    <Verification vendor="in-wrapper"><JavaScriptResource>http://verif/w.js</JavaScriptResource></Verification>
                  </AdVerifications>
                </Extension>
              </Extensions>
            </Wrapper>
          </Ad>
        </VAST>
        """),

        // No Ad elements at all, and a VAST element without a version.
        ("synthetic_no_ads_no_version", "<VAST></VAST>"),

        // Well-formed prefix, then a mismatched end tag: the parser aborts and the parse must report failure.
        ("synthetic_malformed_mismatched_tag", "<VAST version=\"3.0\"><Ad id=\"1\"><InLine><AdSystem>S</Ad></VAST>"),

        // Truncated document.
        ("synthetic_malformed_truncated", "<VAST version=\"3.0\"><Ad id=\"1\"><InLine><AdSystem>S</AdSystem>")
    ]
}
