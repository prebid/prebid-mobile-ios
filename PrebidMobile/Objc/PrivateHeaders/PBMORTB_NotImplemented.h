
#pragma mark - 3.2.5: Metric

//This object is associated with an impression as an array of metrics. These metrics can offer insight into
//the impression to assist with decisioning such as average recent viewability, click-through rate, etc. Each
//metric is identified by its type, reports the value of the metric, and optionally identifies the source or
//vendor measuring the value.
//Note: Metric not supported.


#pragma mark - 3.2.8: Audio

//This object represents an audio type impression. Many of the fields are non-essential for minimally
//    viable transactions, but are included to offer fine control when needed. Audio in OpenRTB generally
//assumes compliance with the DAAST standard. As such, the notion of companion ads is supported by
//optionally including an array of Banner objects (refer to the Banner object in Section 3.2.6) that define
//these companion ads.
//The presence of a Audio as a subordinate of the Imp object indicates that this impression is offered as
//an audio type impression. At the publisher’s discretion, that same impression may also be offered as
//banner, video, and/or native by also including as Imp subordinates objects of those types. However, any
//given bid for the impression must conform to one of the offered types
//Note: Audio is not supported.


#pragma mark - 3.2.9: Native

//This object represents a native type impression. Native ad units are intended to blend seamlessly into the surrounding content (e.g., a sponsored Twitter or Facebook post). As such, the response must be well-structured to afford the publisher fine-grained control over rendering.
//The Native Subcommittee has developed a companion specification to OpenRTB called the Native Ad Specification. It defines the request parameters and response markup structure of native ad units. This object provides the means of transporting request parameters as an opaque string so that the specific parameters can evolve separately under the auspices of the Native Ad Specification. Similarly, the ad markup served will be structured according to that specification.
//Note: Native is not supported.


#pragma mark - 3.2.14: Site

//This object should be included if the ad supported content is a website as opposed to a non-browser
//application. A bid request must not contain both a Site and an App object. At a minimum, it is useful
//to provide a site ID or page URL, but this is not strictly required.
//Note: Site not supported.


#pragma mark - 3.2.17: Producer

//This object defines the producer of the content in which the ad will be shown. This is particularly useful
//when the content is syndicated and may be distributed through different publishers and thus when the
//producer and publisher are not necessarily the same entity.
//Note: Producer not supported.
