// Captured from the ObjC PBMCreativeFactoryJob / PBMTransaction_Objc before they were ported (see CreativeFactoryParityTests).
enum CreativeFactoryParityExpectations {
    static let lines: [String] = """
    interval.0 nil interstitial=false forced=nil => 6
    interval.1 nil interstitial=false forced=Optional(false) => 6
    interval.2 nil interstitial=false forced=Optional(true) => 30
    interval.3 nil interstitial=true forced=nil => 30
    interval.4 nil interstitial=true forced=Optional(false) => 6
    interval.5 nil interstitial=true forced=Optional(true) => 30
    interval.6 banner interstitial=false forced=nil => 6
    interval.7 banner interstitial=false forced=Optional(false) => 6
    interval.8 banner interstitial=false forced=Optional(true) => 30
    interval.9 banner interstitial=true forced=nil => 30
    interval.10 banner interstitial=true forced=Optional(false) => 6
    interval.11 banner interstitial=true forced=Optional(true) => 30
    interval.12 video interstitial=false forced=nil => 30
    interval.13 video interstitial=false forced=Optional(false) => 30
    interval.14 video interstitial=false forced=Optional(true) => 30
    interval.15 video interstitial=true forced=nil => 30
    interval.16 video interstitial=true forced=Optional(false) => 30
    interval.17 video interstitial=true forced=Optional(true) => 30
    interval.18 native interstitial=false forced=nil => 6
    interval.19 native interstitial=false forced=Optional(false) => 6
    interval.20 native interstitial=false forced=Optional(true) => 30
    interval.21 native interstitial=true forced=nil => 30
    interval.22 native interstitial=true forced=Optional(false) => 6
    interval.23 native interstitial=true forced=Optional(true) => 30
    interval.24 videoLookalike interstitial=false forced=nil => 6
    interval.25 videoLookalike interstitial=false forced=Optional(false) => 6
    interval.26 videoLookalike interstitial=false forced=Optional(true) => 30
    interval.27 videoLookalike interstitial=true forced=nil => 30
    interval.28 videoLookalike interstitial=true forced=Optional(false) => 6
    interval.29 videoLookalike interstitial=true forced=Optional(true) => 30
    interval.30 nil interstitial=false forced=nil => 11.1
    interval.31 nil interstitial=false forced=Optional(false) => 11.1
    interval.32 nil interstitial=false forced=Optional(true) => 22.199999999999999
    interval.33 nil interstitial=true forced=nil => 22.199999999999999
    interval.34 nil interstitial=true forced=Optional(false) => 11.1
    interval.35 nil interstitial=true forced=Optional(true) => 22.199999999999999
    interval.36 banner interstitial=false forced=nil => 11.1
    interval.37 banner interstitial=false forced=Optional(false) => 11.1
    interval.38 banner interstitial=false forced=Optional(true) => 22.199999999999999
    interval.39 banner interstitial=true forced=nil => 22.199999999999999
    interval.40 banner interstitial=true forced=Optional(false) => 11.1
    interval.41 banner interstitial=true forced=Optional(true) => 22.199999999999999
    interval.42 video interstitial=false forced=nil => 22.199999999999999
    interval.43 video interstitial=false forced=Optional(false) => 22.199999999999999
    interval.44 video interstitial=false forced=Optional(true) => 22.199999999999999
    interval.45 video interstitial=true forced=nil => 22.199999999999999
    interval.46 video interstitial=true forced=Optional(false) => 22.199999999999999
    interval.47 video interstitial=true forced=Optional(true) => 22.199999999999999
    interval.48 native interstitial=false forced=nil => 11.1
    interval.49 native interstitial=false forced=Optional(false) => 11.1
    interval.50 native interstitial=false forced=Optional(true) => 22.199999999999999
    interval.51 native interstitial=true forced=nil => 22.199999999999999
    interval.52 native interstitial=true forced=Optional(false) => 11.1
    interval.53 native interstitial=true forced=Optional(true) => 22.199999999999999
    interval.54 videoLookalike interstitial=false forced=nil => 11.1
    interval.55 videoLookalike interstitial=false forced=Optional(false) => 11.1
    interval.56 videoLookalike interstitial=false forced=Optional(true) => 22.199999999999999
    interval.57 videoLookalike interstitial=true forced=nil => 22.199999999999999
    interval.58 videoLookalike interstitial=true forced=Optional(false) => 11.1
    interval.59 videoLookalike interstitial=true forced=Optional(true) => 22.199999999999999
    interval.60 nil interstitial=false forced=nil => 0
    interval.61 nil interstitial=false forced=Optional(false) => 0
    interval.62 nil interstitial=false forced=Optional(true) => -1
    interval.63 nil interstitial=true forced=nil => -1
    interval.64 nil interstitial=true forced=Optional(false) => 0
    interval.65 nil interstitial=true forced=Optional(true) => -1
    interval.66 banner interstitial=false forced=nil => 0
    interval.67 banner interstitial=false forced=Optional(false) => 0
    interval.68 banner interstitial=false forced=Optional(true) => -1
    interval.69 banner interstitial=true forced=nil => -1
    interval.70 banner interstitial=true forced=Optional(false) => 0
    interval.71 banner interstitial=true forced=Optional(true) => -1
    interval.72 video interstitial=false forced=nil => -1
    interval.73 video interstitial=false forced=Optional(false) => -1
    interval.74 video interstitial=false forced=Optional(true) => -1
    interval.75 video interstitial=true forced=nil => -1
    interval.76 video interstitial=true forced=Optional(false) => -1
    interval.77 video interstitial=true forced=Optional(true) => -1
    interval.78 native interstitial=false forced=nil => 0
    interval.79 native interstitial=false forced=Optional(false) => 0
    interval.80 native interstitial=false forced=Optional(true) => -1
    interval.81 native interstitial=true forced=nil => -1
    interval.82 native interstitial=true forced=Optional(false) => 0
    interval.83 native interstitial=true forced=Optional(true) => -1
    interval.84 videoLookalike interstitial=false forced=nil => 0
    interval.85 videoLookalike interstitial=false forced=Optional(false) => 0
    interval.86 videoLookalike interstitial=false forced=Optional(true) => -1
    interval.87 videoLookalike interstitial=true forced=nil => -1
    interval.88 videoLookalike interstitial=true forced=Optional(false) => 0
    interval.89 videoLookalike interstitial=true forced=Optional(true) => -1
    interval.90 nil interstitial=false forced=nil => nan
    interval.91 nil interstitial=false forced=Optional(false) => nan
    interval.92 nil interstitial=false forced=Optional(true) => inf
    interval.93 nil interstitial=true forced=nil => inf
    interval.94 nil interstitial=true forced=Optional(false) => nan
    interval.95 nil interstitial=true forced=Optional(true) => inf
    interval.96 banner interstitial=false forced=nil => nan
    interval.97 banner interstitial=false forced=Optional(false) => nan
    interval.98 banner interstitial=false forced=Optional(true) => inf
    interval.99 banner interstitial=true forced=nil => inf
    interval.100 banner interstitial=true forced=Optional(false) => nan
    interval.101 banner interstitial=true forced=Optional(true) => inf
    interval.102 video interstitial=false forced=nil => inf
    interval.103 video interstitial=false forced=Optional(false) => inf
    interval.104 video interstitial=false forced=Optional(true) => inf
    interval.105 video interstitial=true forced=nil => inf
    interval.106 video interstitial=true forced=Optional(false) => inf
    interval.107 video interstitial=true forced=Optional(true) => inf
    interval.108 native interstitial=false forced=nil => nan
    interval.109 native interstitial=false forced=Optional(false) => nan
    interval.110 native interstitial=false forced=Optional(true) => inf
    interval.111 native interstitial=true forced=nil => inf
    interval.112 native interstitial=true forced=Optional(false) => nan
    interval.113 native interstitial=true forced=Optional(true) => inf
    interval.114 videoLookalike interstitial=false forced=nil => nan
    interval.115 videoLookalike interstitial=false forced=Optional(false) => nan
    interval.116 videoLookalike interstitial=false forced=Optional(true) => inf
    interval.117 videoLookalike interstitial=true forced=nil => inf
    interval.118 videoLookalike interstitial=true forced=Optional(false) => nan
    interval.119 videoLookalike interstitial=true forced=Optional(true) => inf
    interval.noconfig => 3.5
    empty.first => nil
    empty.details => nil
    empty.after.0 => nil
    empty.revenue.0 => nil
    one.first => c0
    one.details => raw/tid
    one.after.0 => nil
    one.revenue.0 => rev0
    one.after.1 => c0
    one.revenue.1 => rev0
    three.first => c0
    three.details => raw/tid
    three.after.0 => c1
    three.revenue.0 => nil
    three.after.1 => c2
    three.revenue.1 => rev2
    three.after.2 => nil
    three.revenue.2 => rev2
    three.after.3 => c0
    three.revenue.3 => rev0
    duplicate.first => c0
    duplicate.details => raw/tid
    duplicate.after.0 => c1
    duplicate.revenue.0 => nil
    duplicate.after.1 => c0
    duplicate.revenue.1 => rev0
    duplicate.after.2 => c1
    duplicate.revenue.2 => nil
    duplicate.after.3 => nil
    duplicate.revenue.3 => nil
    duplicate.after.4 => c0
    duplicate.revenue.4 => rev0
    size.0x0 => 0 0
    size.42x7 => 42 7
    size.-3x-4 => -3 -4
    size.2147483647x1 => 2147483647 1
    size.1099511627776x2 => 1099511627776 2
    size.nomodels => 9.0 8.0
    reset => transaction=true models=[true, true]
    session.initial => true
    """.components(separatedBy: "\n")
}
