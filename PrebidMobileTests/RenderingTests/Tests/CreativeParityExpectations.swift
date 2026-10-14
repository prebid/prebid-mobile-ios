// Captured from the ObjC HTMLCreative / VideoCreative before they were ported (see CreativeParityTests).
// swiftlint:disable line_length
enum CreativeParityExpectations {
    static let lines: [String] = """
    vast.0 => false
    vast.1 => false
    vast.2 => true
    vast.3 => false
    vast.4 => false
    vast.5 => true
    vast.6 => true
    vast.7 => true
    vast.8 => false
    vast.9 => false
    vast.10 => false
    vast.11 => true
    vast.12 => true
    vast.13 => false
    vast.14 => true
    vast.15 => true
    vast.16 => true
    vast.17 => false
    vast.18 => true
    vast.19 => false
    vast.20 => false
    vast.21 => false
    vast.22 => true
    vast.23 => true
    vast.24 => true
    vast.25 => false
    vast.26 => true
    vast.27 => true
    vast.28 => true
    max.size => 26214400
    close.comp=false.skip=nil.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=1 => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=100 => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=-3 => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=inf => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=1 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=100 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=-3 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=inf => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=2.5 => 2
    close.comp=false.skip=nil.off=nil.dur=10.pub=0 => 10
    close.comp=false.skip=nil.off=nil.dur=10.pub=1 => 10
    close.comp=false.skip=nil.off=nil.dur=10.pub=5 => 10
    close.comp=false.skip=nil.off=nil.dur=10.pub=100 => 10
    close.comp=false.skip=nil.off=nil.dur=10.pub=-3 => 10
    close.comp=false.skip=nil.off=nil.dur=10.pub=nan => 10
    close.comp=false.skip=nil.off=nil.dur=10.pub=inf => 10
    close.comp=false.skip=nil.off=nil.dur=10.pub=2.5 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=1 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=100 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=-3 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=inf => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=2.5 => 10
    close.comp=false.skip=nil.off=nil.dur=-5.pub=0 => 2
    close.comp=false.skip=nil.off=nil.dur=-5.pub=1 => 2
    close.comp=false.skip=nil.off=nil.dur=-5.pub=5 => 2
    close.comp=false.skip=nil.off=nil.dur=-5.pub=100 => 2
    close.comp=false.skip=nil.off=nil.dur=-5.pub=-3 => 2
    close.comp=false.skip=nil.off=nil.dur=-5.pub=nan => 2
    close.comp=false.skip=nil.off=nil.dur=-5.pub=inf => 2
    close.comp=false.skip=nil.off=nil.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=0 => 10
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=1 => 10
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=5 => 10
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=100 => 10
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=nan => 10
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=inf => 10
    close.comp=false.skip=nil.off=nil.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=0 => 2
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=1 => 2
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=nan => nan
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nil.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=nil.dur=nan.pub=1 => 2
    close.comp=false.skip=nil.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=nil.dur=nan.pub=100 => 30
    close.comp=false.skip=nil.off=nil.dur=nan.pub=-3 => 2
    close.comp=false.skip=nil.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=nil.dur=nan.pub=inf => 30
    close.comp=false.skip=nil.off=nil.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=nil.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=1 => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=100 => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=-3 => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=inf => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=2.5 => 10
    close.comp=false.skip=nil.off=0.dur=nil.pub=0 => 0
    close.comp=false.skip=nil.off=0.dur=nil.pub=1 => 0
    close.comp=false.skip=nil.off=0.dur=nil.pub=5 => 0
    close.comp=false.skip=nil.off=0.dur=nil.pub=100 => 0
    close.comp=false.skip=nil.off=0.dur=nil.pub=-3 => 0
    close.comp=false.skip=nil.off=0.dur=nil.pub=nan => 0
    close.comp=false.skip=nil.off=0.dur=nil.pub=inf => 0
    close.comp=false.skip=nil.off=0.dur=nil.pub=2.5 => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=0 => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=1 => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=5 => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=100 => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=-3 => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=nan => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=inf => 0
    close.comp=false.skip=nil.off=0.dur=0.pub=2.5 => 0
    close.comp=false.skip=nil.off=0.dur=10.pub=0 => 10
    close.comp=false.skip=nil.off=0.dur=10.pub=1 => 10
    close.comp=false.skip=nil.off=0.dur=10.pub=5 => 10
    close.comp=false.skip=nil.off=0.dur=10.pub=100 => 10
    close.comp=false.skip=nil.off=0.dur=10.pub=-3 => 10
    close.comp=false.skip=nil.off=0.dur=10.pub=nan => 10
    close.comp=false.skip=nil.off=0.dur=10.pub=inf => 10
    close.comp=false.skip=nil.off=0.dur=10.pub=2.5 => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=1 => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=100 => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=-3 => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=inf => 10
    close.comp=false.skip=nil.off=0.dur=60.pub=2.5 => 10
    close.comp=false.skip=nil.off=0.dur=-5.pub=0 => 2
    close.comp=false.skip=nil.off=0.dur=-5.pub=1 => 2
    close.comp=false.skip=nil.off=0.dur=-5.pub=5 => 2
    close.comp=false.skip=nil.off=0.dur=-5.pub=100 => 2
    close.comp=false.skip=nil.off=0.dur=-5.pub=-3 => 2
    close.comp=false.skip=nil.off=0.dur=-5.pub=nan => 2
    close.comp=false.skip=nil.off=0.dur=-5.pub=inf => 2
    close.comp=false.skip=nil.off=0.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=0 => 10
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=1 => 10
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=5 => 10
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=100 => 10
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=nan => 10
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=inf => 10
    close.comp=false.skip=nil.off=0.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=nil.off=0.dur=2.5.pub=0 => 0
    close.comp=false.skip=nil.off=0.dur=2.5.pub=1 => 0
    close.comp=false.skip=nil.off=0.dur=2.5.pub=5 => 0
    close.comp=false.skip=nil.off=0.dur=2.5.pub=100 => 0
    close.comp=false.skip=nil.off=0.dur=2.5.pub=-3 => 0
    close.comp=false.skip=nil.off=0.dur=2.5.pub=nan => 0
    close.comp=false.skip=nil.off=0.dur=2.5.pub=inf => 0
    close.comp=false.skip=nil.off=0.dur=2.5.pub=2.5 => 0
    close.comp=false.skip=nil.off=0.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=0.dur=nan.pub=1 => 2
    close.comp=false.skip=nil.off=0.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=0.dur=nan.pub=100 => 30
    close.comp=false.skip=nil.off=0.dur=nan.pub=-3 => 2
    close.comp=false.skip=nil.off=0.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=0.dur=nan.pub=inf => 30
    close.comp=false.skip=nil.off=0.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=0.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=0.dur=inf.pub=1 => 10
    close.comp=false.skip=nil.off=0.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=0.dur=inf.pub=100 => 10
    close.comp=false.skip=nil.off=0.dur=inf.pub=-3 => 10
    close.comp=false.skip=nil.off=0.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=0.dur=inf.pub=inf => 10
    close.comp=false.skip=nil.off=0.dur=inf.pub=2.5 => 10
    close.comp=false.skip=nil.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=1 => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=100 => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=-3 => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=inf => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=1 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=100 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=-3 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=inf => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=2.5 => 2
    close.comp=false.skip=nil.off=4.dur=10.pub=0 => 10
    close.comp=false.skip=nil.off=4.dur=10.pub=1 => 10
    close.comp=false.skip=nil.off=4.dur=10.pub=5 => 10
    close.comp=false.skip=nil.off=4.dur=10.pub=100 => 10
    close.comp=false.skip=nil.off=4.dur=10.pub=-3 => 10
    close.comp=false.skip=nil.off=4.dur=10.pub=nan => 10
    close.comp=false.skip=nil.off=4.dur=10.pub=inf => 10
    close.comp=false.skip=nil.off=4.dur=10.pub=2.5 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=1 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=100 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=-3 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=inf => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=2.5 => 10
    close.comp=false.skip=nil.off=4.dur=-5.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=-5.pub=1 => 2
    close.comp=false.skip=nil.off=4.dur=-5.pub=5 => 2
    close.comp=false.skip=nil.off=4.dur=-5.pub=100 => 2
    close.comp=false.skip=nil.off=4.dur=-5.pub=-3 => 2
    close.comp=false.skip=nil.off=4.dur=-5.pub=nan => 2
    close.comp=false.skip=nil.off=4.dur=-5.pub=inf => 2
    close.comp=false.skip=nil.off=4.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=0 => 10
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=1 => 10
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=5 => 10
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=100 => 10
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=nan => 10
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=inf => 10
    close.comp=false.skip=nil.off=4.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=nil.off=4.dur=2.5.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=2.5.pub=1 => 2
    close.comp=false.skip=nil.off=4.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nil.off=4.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nil.off=4.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nil.off=4.dur=2.5.pub=nan => nan
    close.comp=false.skip=nil.off=4.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nil.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=nan.pub=1 => 2
    close.comp=false.skip=nil.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=4.dur=nan.pub=100 => 30
    close.comp=false.skip=nil.off=4.dur=nan.pub=-3 => 2
    close.comp=false.skip=nil.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=4.dur=nan.pub=inf => 30
    close.comp=false.skip=nil.off=4.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=4.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=1 => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=100 => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=-3 => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=inf => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=2.5 => 10
    close.comp=false.skip=nil.off=20.dur=nil.pub=0 => 2
    close.comp=false.skip=nil.off=20.dur=nil.pub=1 => 2
    close.comp=false.skip=nil.off=20.dur=nil.pub=5 => 2
    close.comp=false.skip=nil.off=20.dur=nil.pub=100 => 2
    close.comp=false.skip=nil.off=20.dur=nil.pub=-3 => 2
    close.comp=false.skip=nil.off=20.dur=nil.pub=nan => 2
    close.comp=false.skip=nil.off=20.dur=nil.pub=inf => 2
    close.comp=false.skip=nil.off=20.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=0 => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=1 => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=5 => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=100 => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=-3 => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=nan => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=inf => 2
    close.comp=false.skip=nil.off=20.dur=0.pub=2.5 => 2
    close.comp=false.skip=nil.off=20.dur=10.pub=0 => 10
    close.comp=false.skip=nil.off=20.dur=10.pub=1 => 10
    close.comp=false.skip=nil.off=20.dur=10.pub=5 => 10
    close.comp=false.skip=nil.off=20.dur=10.pub=100 => 10
    close.comp=false.skip=nil.off=20.dur=10.pub=-3 => 10
    close.comp=false.skip=nil.off=20.dur=10.pub=nan => 10
    close.comp=false.skip=nil.off=20.dur=10.pub=inf => 10
    close.comp=false.skip=nil.off=20.dur=10.pub=2.5 => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=1 => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=100 => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=-3 => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=inf => 10
    close.comp=false.skip=nil.off=20.dur=60.pub=2.5 => 10
    close.comp=false.skip=nil.off=20.dur=-5.pub=0 => 2
    close.comp=false.skip=nil.off=20.dur=-5.pub=1 => 2
    close.comp=false.skip=nil.off=20.dur=-5.pub=5 => 2
    close.comp=false.skip=nil.off=20.dur=-5.pub=100 => 2
    close.comp=false.skip=nil.off=20.dur=-5.pub=-3 => 2
    close.comp=false.skip=nil.off=20.dur=-5.pub=nan => 2
    close.comp=false.skip=nil.off=20.dur=-5.pub=inf => 2
    close.comp=false.skip=nil.off=20.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=0 => 10
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=1 => 10
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=5 => 10
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=100 => 10
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=nan => 10
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=inf => 10
    close.comp=false.skip=nil.off=20.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=nil.off=20.dur=2.5.pub=0 => 2
    close.comp=false.skip=nil.off=20.dur=2.5.pub=1 => 2
    close.comp=false.skip=nil.off=20.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nil.off=20.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nil.off=20.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nil.off=20.dur=2.5.pub=nan => nan
    close.comp=false.skip=nil.off=20.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nil.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=20.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=20.dur=nan.pub=1 => 2
    close.comp=false.skip=nil.off=20.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=20.dur=nan.pub=100 => 30
    close.comp=false.skip=nil.off=20.dur=nan.pub=-3 => 2
    close.comp=false.skip=nil.off=20.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=20.dur=nan.pub=inf => 30
    close.comp=false.skip=nil.off=20.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=20.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=20.dur=inf.pub=1 => 10
    close.comp=false.skip=nil.off=20.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=20.dur=inf.pub=100 => 10
    close.comp=false.skip=nil.off=20.dur=inf.pub=-3 => 10
    close.comp=false.skip=nil.off=20.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=20.dur=inf.pub=inf => 10
    close.comp=false.skip=nil.off=20.dur=inf.pub=2.5 => 10
    close.comp=false.skip=nil.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=1 => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=100 => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=-3 => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=inf => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=2.5 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=1 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=100 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=-3 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=inf => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=2.5 => -1
    close.comp=false.skip=nil.off=-1.dur=10.pub=0 => 10
    close.comp=false.skip=nil.off=-1.dur=10.pub=1 => 10
    close.comp=false.skip=nil.off=-1.dur=10.pub=5 => 10
    close.comp=false.skip=nil.off=-1.dur=10.pub=100 => 10
    close.comp=false.skip=nil.off=-1.dur=10.pub=-3 => 10
    close.comp=false.skip=nil.off=-1.dur=10.pub=nan => 10
    close.comp=false.skip=nil.off=-1.dur=10.pub=inf => 10
    close.comp=false.skip=nil.off=-1.dur=10.pub=2.5 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=1 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=100 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=-3 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=inf => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=2.5 => 10
    close.comp=false.skip=nil.off=-1.dur=-5.pub=0 => 2
    close.comp=false.skip=nil.off=-1.dur=-5.pub=1 => 2
    close.comp=false.skip=nil.off=-1.dur=-5.pub=5 => 2
    close.comp=false.skip=nil.off=-1.dur=-5.pub=100 => 2
    close.comp=false.skip=nil.off=-1.dur=-5.pub=-3 => 2
    close.comp=false.skip=nil.off=-1.dur=-5.pub=nan => 2
    close.comp=false.skip=nil.off=-1.dur=-5.pub=inf => 2
    close.comp=false.skip=nil.off=-1.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=0 => 10
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=1 => 10
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=5 => 10
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=100 => 10
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=nan => 10
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=inf => 10
    close.comp=false.skip=nil.off=-1.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=0 => -1
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=1 => -1
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=5 => -1
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=100 => -1
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=-3 => -1
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=nan => -1
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=inf => -1
    close.comp=false.skip=nil.off=-1.dur=2.5.pub=2.5 => -1
    close.comp=false.skip=nil.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=-1.dur=nan.pub=1 => 2
    close.comp=false.skip=nil.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=-1.dur=nan.pub=100 => 30
    close.comp=false.skip=nil.off=-1.dur=nan.pub=-3 => 2
    close.comp=false.skip=nil.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=-1.dur=nan.pub=inf => 30
    close.comp=false.skip=nil.off=-1.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=-1.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=1 => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=100 => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=-3 => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=inf => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=2.5 => 10
    close.comp=false.skip=nil.off=10.dur=nil.pub=0 => 2
    close.comp=false.skip=nil.off=10.dur=nil.pub=1 => 2
    close.comp=false.skip=nil.off=10.dur=nil.pub=5 => 2
    close.comp=false.skip=nil.off=10.dur=nil.pub=100 => 2
    close.comp=false.skip=nil.off=10.dur=nil.pub=-3 => 2
    close.comp=false.skip=nil.off=10.dur=nil.pub=nan => 2
    close.comp=false.skip=nil.off=10.dur=nil.pub=inf => 2
    close.comp=false.skip=nil.off=10.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=0 => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=1 => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=5 => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=100 => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=-3 => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=nan => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=inf => 2
    close.comp=false.skip=nil.off=10.dur=0.pub=2.5 => 2
    close.comp=false.skip=nil.off=10.dur=10.pub=0 => 10
    close.comp=false.skip=nil.off=10.dur=10.pub=1 => 10
    close.comp=false.skip=nil.off=10.dur=10.pub=5 => 10
    close.comp=false.skip=nil.off=10.dur=10.pub=100 => 10
    close.comp=false.skip=nil.off=10.dur=10.pub=-3 => 10
    close.comp=false.skip=nil.off=10.dur=10.pub=nan => 10
    close.comp=false.skip=nil.off=10.dur=10.pub=inf => 10
    close.comp=false.skip=nil.off=10.dur=10.pub=2.5 => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=1 => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=100 => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=-3 => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=inf => 10
    close.comp=false.skip=nil.off=10.dur=60.pub=2.5 => 10
    close.comp=false.skip=nil.off=10.dur=-5.pub=0 => 2
    close.comp=false.skip=nil.off=10.dur=-5.pub=1 => 2
    close.comp=false.skip=nil.off=10.dur=-5.pub=5 => 2
    close.comp=false.skip=nil.off=10.dur=-5.pub=100 => 2
    close.comp=false.skip=nil.off=10.dur=-5.pub=-3 => 2
    close.comp=false.skip=nil.off=10.dur=-5.pub=nan => 2
    close.comp=false.skip=nil.off=10.dur=-5.pub=inf => 2
    close.comp=false.skip=nil.off=10.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=0 => 10
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=1 => 10
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=5 => 10
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=100 => 10
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=nan => 10
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=inf => 10
    close.comp=false.skip=nil.off=10.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=nil.off=10.dur=2.5.pub=0 => 2
    close.comp=false.skip=nil.off=10.dur=2.5.pub=1 => 2
    close.comp=false.skip=nil.off=10.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nil.off=10.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nil.off=10.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nil.off=10.dur=2.5.pub=nan => nan
    close.comp=false.skip=nil.off=10.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nil.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=10.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=10.dur=nan.pub=1 => 2
    close.comp=false.skip=nil.off=10.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=10.dur=nan.pub=100 => 30
    close.comp=false.skip=nil.off=10.dur=nan.pub=-3 => 2
    close.comp=false.skip=nil.off=10.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=10.dur=nan.pub=inf => 30
    close.comp=false.skip=nil.off=10.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nil.off=10.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=10.dur=inf.pub=1 => 10
    close.comp=false.skip=nil.off=10.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=10.dur=inf.pub=100 => 10
    close.comp=false.skip=nil.off=10.dur=inf.pub=-3 => 10
    close.comp=false.skip=nil.off=10.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=10.dur=inf.pub=inf => 10
    close.comp=false.skip=nil.off=10.dur=inf.pub=2.5 => 10
    close.comp=false.skip=0.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=nil.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=0.off=nil.dur=nil.pub=100 => 2
    close.comp=false.skip=0.off=nil.dur=nil.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=0.off=nil.dur=nil.pub=inf => 2
    close.comp=false.skip=0.off=nil.dur=nil.pub=2.5 => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=100 => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=inf => 2
    close.comp=false.skip=0.off=nil.dur=0.pub=2.5 => 2
    close.comp=false.skip=0.off=nil.dur=10.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=10.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=10.pub=5 => 5
    close.comp=false.skip=0.off=nil.dur=10.pub=100 => 10
    close.comp=false.skip=0.off=nil.dur=10.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=10.pub=nan => nan
    close.comp=false.skip=0.off=nil.dur=10.pub=inf => 10
    close.comp=false.skip=0.off=nil.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=0.off=nil.dur=60.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=60.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=60.pub=5 => 5
    close.comp=false.skip=0.off=nil.dur=60.pub=100 => 30
    close.comp=false.skip=0.off=nil.dur=60.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=60.pub=nan => nan
    close.comp=false.skip=0.off=nil.dur=60.pub=inf => 30
    close.comp=false.skip=0.off=nil.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=0.off=nil.dur=-5.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=-5.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=-5.pub=5 => 2
    close.comp=false.skip=0.off=nil.dur=-5.pub=100 => 2
    close.comp=false.skip=0.off=nil.dur=-5.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=-5.pub=nan => 2
    close.comp=false.skip=0.off=nil.dur=-5.pub=inf => 2
    close.comp=false.skip=0.off=nil.dur=-5.pub=2.5 => 2
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=5 => 5
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=100 => 30
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=nan => nan
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=inf => 30
    close.comp=false.skip=0.off=nil.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=0.off=nil.dur=2.5.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=2.5.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=0.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=0.off=nil.dur=2.5.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=2.5.pub=nan => nan
    close.comp=false.skip=0.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=0.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=0.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=nan.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=0.off=nil.dur=nan.pub=100 => 30
    close.comp=false.skip=0.off=nil.dur=nan.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=0.off=nil.dur=nan.pub=inf => 30
    close.comp=false.skip=0.off=nil.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=0.off=nil.dur=inf.pub=0 => 2
    close.comp=false.skip=0.off=nil.dur=inf.pub=1 => 2
    close.comp=false.skip=0.off=nil.dur=inf.pub=5 => 5
    close.comp=false.skip=0.off=nil.dur=inf.pub=100 => 30
    close.comp=false.skip=0.off=nil.dur=inf.pub=-3 => 2
    close.comp=false.skip=0.off=nil.dur=inf.pub=nan => nan
    close.comp=false.skip=0.off=nil.dur=inf.pub=inf => 30
    close.comp=false.skip=0.off=nil.dur=inf.pub=2.5 => 2.5
    close.comp=false.skip=0.off=0.dur=nil.pub=0 => 0
    close.comp=false.skip=0.off=0.dur=nil.pub=1 => 0
    close.comp=false.skip=0.off=0.dur=nil.pub=5 => 0
    close.comp=false.skip=0.off=0.dur=nil.pub=100 => 0
    close.comp=false.skip=0.off=0.dur=nil.pub=-3 => 0
    close.comp=false.skip=0.off=0.dur=nil.pub=nan => 0
    close.comp=false.skip=0.off=0.dur=nil.pub=inf => 0
    close.comp=false.skip=0.off=0.dur=nil.pub=2.5 => 0
    close.comp=false.skip=0.off=0.dur=0.pub=0 => 0
    close.comp=false.skip=0.off=0.dur=0.pub=1 => 0
    close.comp=false.skip=0.off=0.dur=0.pub=5 => 0
    close.comp=false.skip=0.off=0.dur=0.pub=100 => 0
    close.comp=false.skip=0.off=0.dur=0.pub=-3 => 0
    close.comp=false.skip=0.off=0.dur=0.pub=nan => 0
    close.comp=false.skip=0.off=0.dur=0.pub=inf => 0
    close.comp=false.skip=0.off=0.dur=0.pub=2.5 => 0
    close.comp=false.skip=0.off=0.dur=10.pub=0 => 0
    close.comp=false.skip=0.off=0.dur=10.pub=1 => 0
    close.comp=false.skip=0.off=0.dur=10.pub=5 => 0
    close.comp=false.skip=0.off=0.dur=10.pub=100 => 0
    close.comp=false.skip=0.off=0.dur=10.pub=-3 => 0
    close.comp=false.skip=0.off=0.dur=10.pub=nan => 0
    close.comp=false.skip=0.off=0.dur=10.pub=inf => 0
    close.comp=false.skip=0.off=0.dur=10.pub=2.5 => 0
    close.comp=false.skip=0.off=0.dur=60.pub=0 => 0
    close.comp=false.skip=0.off=0.dur=60.pub=1 => 0
    close.comp=false.skip=0.off=0.dur=60.pub=5 => 0
    close.comp=false.skip=0.off=0.dur=60.pub=100 => 0
    close.comp=false.skip=0.off=0.dur=60.pub=-3 => 0
    close.comp=false.skip=0.off=0.dur=60.pub=nan => 0
    close.comp=false.skip=0.off=0.dur=60.pub=inf => 0
    close.comp=false.skip=0.off=0.dur=60.pub=2.5 => 0
    close.comp=false.skip=0.off=0.dur=-5.pub=0 => 2
    close.comp=false.skip=0.off=0.dur=-5.pub=1 => 2
    close.comp=false.skip=0.off=0.dur=-5.pub=5 => 2
    close.comp=false.skip=0.off=0.dur=-5.pub=100 => 2
    close.comp=false.skip=0.off=0.dur=-5.pub=-3 => 2
    close.comp=false.skip=0.off=0.dur=-5.pub=nan => 2
    close.comp=false.skip=0.off=0.dur=-5.pub=inf => 2
    close.comp=false.skip=0.off=0.dur=-5.pub=2.5 => 2
    close.comp=false.skip=0.off=0.dur=1000000000.pub=0 => 0
    close.comp=false.skip=0.off=0.dur=1000000000.pub=1 => 0
    close.comp=false.skip=0.off=0.dur=1000000000.pub=5 => 0
    close.comp=false.skip=0.off=0.dur=1000000000.pub=100 => 0
    close.comp=false.skip=0.off=0.dur=1000000000.pub=-3 => 0
    close.comp=false.skip=0.off=0.dur=1000000000.pub=nan => 0
    close.comp=false.skip=0.off=0.dur=1000000000.pub=inf => 0
    close.comp=false.skip=0.off=0.dur=1000000000.pub=2.5 => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=0 => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=1 => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=5 => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=100 => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=-3 => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=nan => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=inf => 0
    close.comp=false.skip=0.off=0.dur=2.5.pub=2.5 => 0
    close.comp=false.skip=0.off=0.dur=nan.pub=0 => 2
    close.comp=false.skip=0.off=0.dur=nan.pub=1 => 2
    close.comp=false.skip=0.off=0.dur=nan.pub=5 => 5
    close.comp=false.skip=0.off=0.dur=nan.pub=100 => 30
    close.comp=false.skip=0.off=0.dur=nan.pub=-3 => 2
    close.comp=false.skip=0.off=0.dur=nan.pub=nan => nan
    close.comp=false.skip=0.off=0.dur=nan.pub=inf => 30
    close.comp=false.skip=0.off=0.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=0.off=0.dur=inf.pub=0 => 0
    close.comp=false.skip=0.off=0.dur=inf.pub=1 => 0
    close.comp=false.skip=0.off=0.dur=inf.pub=5 => 0
    close.comp=false.skip=0.off=0.dur=inf.pub=100 => 0
    close.comp=false.skip=0.off=0.dur=inf.pub=-3 => 0
    close.comp=false.skip=0.off=0.dur=inf.pub=nan => 0
    close.comp=false.skip=0.off=0.dur=inf.pub=inf => 0
    close.comp=false.skip=0.off=0.dur=inf.pub=2.5 => 0
    close.comp=false.skip=0.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=0.off=4.dur=nil.pub=1 => 2
    close.comp=false.skip=0.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=0.off=4.dur=nil.pub=100 => 2
    close.comp=false.skip=0.off=4.dur=nil.pub=-3 => 2
    close.comp=false.skip=0.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=0.off=4.dur=nil.pub=inf => 2
    close.comp=false.skip=0.off=4.dur=nil.pub=2.5 => 2
    close.comp=false.skip=0.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=0.off=4.dur=0.pub=1 => 2
    close.comp=false.skip=0.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=0.off=4.dur=0.pub=100 => 2
    close.comp=false.skip=0.off=4.dur=0.pub=-3 => 2
    close.comp=false.skip=0.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=0.off=4.dur=0.pub=inf => 2
    close.comp=false.skip=0.off=4.dur=0.pub=2.5 => 2
    close.comp=false.skip=0.off=4.dur=10.pub=0 => 4
    close.comp=false.skip=0.off=4.dur=10.pub=1 => 4
    close.comp=false.skip=0.off=4.dur=10.pub=5 => 4
    close.comp=false.skip=0.off=4.dur=10.pub=100 => 4
    close.comp=false.skip=0.off=4.dur=10.pub=-3 => 4
    close.comp=false.skip=0.off=4.dur=10.pub=nan => 4
    close.comp=false.skip=0.off=4.dur=10.pub=inf => 4
    close.comp=false.skip=0.off=4.dur=10.pub=2.5 => 4
    close.comp=false.skip=0.off=4.dur=60.pub=0 => 4
    close.comp=false.skip=0.off=4.dur=60.pub=1 => 4
    close.comp=false.skip=0.off=4.dur=60.pub=5 => 4
    close.comp=false.skip=0.off=4.dur=60.pub=100 => 4
    close.comp=false.skip=0.off=4.dur=60.pub=-3 => 4
    close.comp=false.skip=0.off=4.dur=60.pub=nan => 4
    close.comp=false.skip=0.off=4.dur=60.pub=inf => 4
    close.comp=false.skip=0.off=4.dur=60.pub=2.5 => 4
    close.comp=false.skip=0.off=4.dur=-5.pub=0 => 2
    close.comp=false.skip=0.off=4.dur=-5.pub=1 => 2
    close.comp=false.skip=0.off=4.dur=-5.pub=5 => 2
    close.comp=false.skip=0.off=4.dur=-5.pub=100 => 2
    close.comp=false.skip=0.off=4.dur=-5.pub=-3 => 2
    close.comp=false.skip=0.off=4.dur=-5.pub=nan => 2
    close.comp=false.skip=0.off=4.dur=-5.pub=inf => 2
    close.comp=false.skip=0.off=4.dur=-5.pub=2.5 => 2
    close.comp=false.skip=0.off=4.dur=1000000000.pub=0 => 4
    close.comp=false.skip=0.off=4.dur=1000000000.pub=1 => 4
    close.comp=false.skip=0.off=4.dur=1000000000.pub=5 => 4
    close.comp=false.skip=0.off=4.dur=1000000000.pub=100 => 4
    close.comp=false.skip=0.off=4.dur=1000000000.pub=-3 => 4
    close.comp=false.skip=0.off=4.dur=1000000000.pub=nan => 4
    close.comp=false.skip=0.off=4.dur=1000000000.pub=inf => 4
    close.comp=false.skip=0.off=4.dur=1000000000.pub=2.5 => 4
    close.comp=false.skip=0.off=4.dur=2.5.pub=0 => 2
    close.comp=false.skip=0.off=4.dur=2.5.pub=1 => 2
    close.comp=false.skip=0.off=4.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=0.off=4.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=0.off=4.dur=2.5.pub=-3 => 2
    close.comp=false.skip=0.off=4.dur=2.5.pub=nan => nan
    close.comp=false.skip=0.off=4.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=0.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=0.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=0.off=4.dur=nan.pub=1 => 2
    close.comp=false.skip=0.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=0.off=4.dur=nan.pub=100 => 30
    close.comp=false.skip=0.off=4.dur=nan.pub=-3 => 2
    close.comp=false.skip=0.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=0.off=4.dur=nan.pub=inf => 30
    close.comp=false.skip=0.off=4.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=0.off=4.dur=inf.pub=0 => 4
    close.comp=false.skip=0.off=4.dur=inf.pub=1 => 4
    close.comp=false.skip=0.off=4.dur=inf.pub=5 => 4
    close.comp=false.skip=0.off=4.dur=inf.pub=100 => 4
    close.comp=false.skip=0.off=4.dur=inf.pub=-3 => 4
    close.comp=false.skip=0.off=4.dur=inf.pub=nan => 4
    close.comp=false.skip=0.off=4.dur=inf.pub=inf => 4
    close.comp=false.skip=0.off=4.dur=inf.pub=2.5 => 4
    close.comp=false.skip=0.off=20.dur=nil.pub=0 => 2
    close.comp=false.skip=0.off=20.dur=nil.pub=1 => 2
    close.comp=false.skip=0.off=20.dur=nil.pub=5 => 2
    close.comp=false.skip=0.off=20.dur=nil.pub=100 => 2
    close.comp=false.skip=0.off=20.dur=nil.pub=-3 => 2
    close.comp=false.skip=0.off=20.dur=nil.pub=nan => 2
    close.comp=false.skip=0.off=20.dur=nil.pub=inf => 2
    close.comp=false.skip=0.off=20.dur=nil.pub=2.5 => 2
    close.comp=false.skip=0.off=20.dur=0.pub=0 => 2
    close.comp=false.skip=0.off=20.dur=0.pub=1 => 2
    close.comp=false.skip=0.off=20.dur=0.pub=5 => 2
    close.comp=false.skip=0.off=20.dur=0.pub=100 => 2
    close.comp=false.skip=0.off=20.dur=0.pub=-3 => 2
    close.comp=false.skip=0.off=20.dur=0.pub=nan => 2
    close.comp=false.skip=0.off=20.dur=0.pub=inf => 2
    close.comp=false.skip=0.off=20.dur=0.pub=2.5 => 2
    close.comp=false.skip=0.off=20.dur=10.pub=0 => 2
    close.comp=false.skip=0.off=20.dur=10.pub=1 => 2
    close.comp=false.skip=0.off=20.dur=10.pub=5 => 5
    close.comp=false.skip=0.off=20.dur=10.pub=100 => 10
    close.comp=false.skip=0.off=20.dur=10.pub=-3 => 2
    close.comp=false.skip=0.off=20.dur=10.pub=nan => nan
    close.comp=false.skip=0.off=20.dur=10.pub=inf => 10
    close.comp=false.skip=0.off=20.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=0.off=20.dur=60.pub=0 => 20
    close.comp=false.skip=0.off=20.dur=60.pub=1 => 20
    close.comp=false.skip=0.off=20.dur=60.pub=5 => 20
    close.comp=false.skip=0.off=20.dur=60.pub=100 => 20
    close.comp=false.skip=0.off=20.dur=60.pub=-3 => 20
    close.comp=false.skip=0.off=20.dur=60.pub=nan => 20
    close.comp=false.skip=0.off=20.dur=60.pub=inf => 20
    close.comp=false.skip=0.off=20.dur=60.pub=2.5 => 20
    close.comp=false.skip=0.off=20.dur=-5.pub=0 => 2
    close.comp=false.skip=0.off=20.dur=-5.pub=1 => 2
    close.comp=false.skip=0.off=20.dur=-5.pub=5 => 2
    close.comp=false.skip=0.off=20.dur=-5.pub=100 => 2
    close.comp=false.skip=0.off=20.dur=-5.pub=-3 => 2
    close.comp=false.skip=0.off=20.dur=-5.pub=nan => 2
    close.comp=false.skip=0.off=20.dur=-5.pub=inf => 2
    close.comp=false.skip=0.off=20.dur=-5.pub=2.5 => 2
    close.comp=false.skip=0.off=20.dur=1000000000.pub=0 => 20
    close.comp=false.skip=0.off=20.dur=1000000000.pub=1 => 20
    close.comp=false.skip=0.off=20.dur=1000000000.pub=5 => 20
    close.comp=false.skip=0.off=20.dur=1000000000.pub=100 => 20
    close.comp=false.skip=0.off=20.dur=1000000000.pub=-3 => 20
    close.comp=false.skip=0.off=20.dur=1000000000.pub=nan => 20
    close.comp=false.skip=0.off=20.dur=1000000000.pub=inf => 20
    close.comp=false.skip=0.off=20.dur=1000000000.pub=2.5 => 20
    close.comp=false.skip=0.off=20.dur=2.5.pub=0 => 2
    close.comp=false.skip=0.off=20.dur=2.5.pub=1 => 2
    close.comp=false.skip=0.off=20.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=0.off=20.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=0.off=20.dur=2.5.pub=-3 => 2
    close.comp=false.skip=0.off=20.dur=2.5.pub=nan => nan
    close.comp=false.skip=0.off=20.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=0.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=0.off=20.dur=nan.pub=0 => 2
    close.comp=false.skip=0.off=20.dur=nan.pub=1 => 2
    close.comp=false.skip=0.off=20.dur=nan.pub=5 => 5
    close.comp=false.skip=0.off=20.dur=nan.pub=100 => 30
    close.comp=false.skip=0.off=20.dur=nan.pub=-3 => 2
    close.comp=false.skip=0.off=20.dur=nan.pub=nan => nan
    close.comp=false.skip=0.off=20.dur=nan.pub=inf => 30
    close.comp=false.skip=0.off=20.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=0.off=20.dur=inf.pub=0 => 20
    close.comp=false.skip=0.off=20.dur=inf.pub=1 => 20
    close.comp=false.skip=0.off=20.dur=inf.pub=5 => 20
    close.comp=false.skip=0.off=20.dur=inf.pub=100 => 20
    close.comp=false.skip=0.off=20.dur=inf.pub=-3 => 20
    close.comp=false.skip=0.off=20.dur=inf.pub=nan => 20
    close.comp=false.skip=0.off=20.dur=inf.pub=inf => 20
    close.comp=false.skip=0.off=20.dur=inf.pub=2.5 => 20
    close.comp=false.skip=0.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=0.off=-1.dur=nil.pub=1 => -1
    close.comp=false.skip=0.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=0.off=-1.dur=nil.pub=100 => -1
    close.comp=false.skip=0.off=-1.dur=nil.pub=-3 => -1
    close.comp=false.skip=0.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=0.off=-1.dur=nil.pub=inf => -1
    close.comp=false.skip=0.off=-1.dur=nil.pub=2.5 => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=1 => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=100 => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=-3 => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=inf => -1
    close.comp=false.skip=0.off=-1.dur=0.pub=2.5 => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=0 => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=1 => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=5 => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=100 => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=-3 => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=nan => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=inf => -1
    close.comp=false.skip=0.off=-1.dur=10.pub=2.5 => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=0 => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=1 => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=5 => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=100 => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=-3 => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=nan => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=inf => -1
    close.comp=false.skip=0.off=-1.dur=60.pub=2.5 => -1
    close.comp=false.skip=0.off=-1.dur=-5.pub=0 => 2
    close.comp=false.skip=0.off=-1.dur=-5.pub=1 => 2
    close.comp=false.skip=0.off=-1.dur=-5.pub=5 => 2
    close.comp=false.skip=0.off=-1.dur=-5.pub=100 => 2
    close.comp=false.skip=0.off=-1.dur=-5.pub=-3 => 2
    close.comp=false.skip=0.off=-1.dur=-5.pub=nan => 2
    close.comp=false.skip=0.off=-1.dur=-5.pub=inf => 2
    close.comp=false.skip=0.off=-1.dur=-5.pub=2.5 => 2
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=0 => -1
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=1 => -1
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=5 => -1
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=100 => -1
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=-3 => -1
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=nan => -1
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=inf => -1
    close.comp=false.skip=0.off=-1.dur=1000000000.pub=2.5 => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=0 => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=1 => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=5 => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=100 => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=-3 => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=nan => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=inf => -1
    close.comp=false.skip=0.off=-1.dur=2.5.pub=2.5 => -1
    close.comp=false.skip=0.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=0.off=-1.dur=nan.pub=1 => 2
    close.comp=false.skip=0.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=0.off=-1.dur=nan.pub=100 => 30
    close.comp=false.skip=0.off=-1.dur=nan.pub=-3 => 2
    close.comp=false.skip=0.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=0.off=-1.dur=nan.pub=inf => 30
    close.comp=false.skip=0.off=-1.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=0.off=-1.dur=inf.pub=0 => -1
    close.comp=false.skip=0.off=-1.dur=inf.pub=1 => -1
    close.comp=false.skip=0.off=-1.dur=inf.pub=5 => -1
    close.comp=false.skip=0.off=-1.dur=inf.pub=100 => -1
    close.comp=false.skip=0.off=-1.dur=inf.pub=-3 => -1
    close.comp=false.skip=0.off=-1.dur=inf.pub=nan => -1
    close.comp=false.skip=0.off=-1.dur=inf.pub=inf => -1
    close.comp=false.skip=0.off=-1.dur=inf.pub=2.5 => -1
    close.comp=false.skip=0.off=10.dur=nil.pub=0 => 2
    close.comp=false.skip=0.off=10.dur=nil.pub=1 => 2
    close.comp=false.skip=0.off=10.dur=nil.pub=5 => 2
    close.comp=false.skip=0.off=10.dur=nil.pub=100 => 2
    close.comp=false.skip=0.off=10.dur=nil.pub=-3 => 2
    close.comp=false.skip=0.off=10.dur=nil.pub=nan => 2
    close.comp=false.skip=0.off=10.dur=nil.pub=inf => 2
    close.comp=false.skip=0.off=10.dur=nil.pub=2.5 => 2
    close.comp=false.skip=0.off=10.dur=0.pub=0 => 2
    close.comp=false.skip=0.off=10.dur=0.pub=1 => 2
    close.comp=false.skip=0.off=10.dur=0.pub=5 => 2
    close.comp=false.skip=0.off=10.dur=0.pub=100 => 2
    close.comp=false.skip=0.off=10.dur=0.pub=-3 => 2
    close.comp=false.skip=0.off=10.dur=0.pub=nan => 2
    close.comp=false.skip=0.off=10.dur=0.pub=inf => 2
    close.comp=false.skip=0.off=10.dur=0.pub=2.5 => 2
    close.comp=false.skip=0.off=10.dur=10.pub=0 => 10
    close.comp=false.skip=0.off=10.dur=10.pub=1 => 10
    close.comp=false.skip=0.off=10.dur=10.pub=5 => 10
    close.comp=false.skip=0.off=10.dur=10.pub=100 => 10
    close.comp=false.skip=0.off=10.dur=10.pub=-3 => 10
    close.comp=false.skip=0.off=10.dur=10.pub=nan => 10
    close.comp=false.skip=0.off=10.dur=10.pub=inf => 10
    close.comp=false.skip=0.off=10.dur=10.pub=2.5 => 10
    close.comp=false.skip=0.off=10.dur=60.pub=0 => 10
    close.comp=false.skip=0.off=10.dur=60.pub=1 => 10
    close.comp=false.skip=0.off=10.dur=60.pub=5 => 10
    close.comp=false.skip=0.off=10.dur=60.pub=100 => 10
    close.comp=false.skip=0.off=10.dur=60.pub=-3 => 10
    close.comp=false.skip=0.off=10.dur=60.pub=nan => 10
    close.comp=false.skip=0.off=10.dur=60.pub=inf => 10
    close.comp=false.skip=0.off=10.dur=60.pub=2.5 => 10
    close.comp=false.skip=0.off=10.dur=-5.pub=0 => 2
    close.comp=false.skip=0.off=10.dur=-5.pub=1 => 2
    close.comp=false.skip=0.off=10.dur=-5.pub=5 => 2
    close.comp=false.skip=0.off=10.dur=-5.pub=100 => 2
    close.comp=false.skip=0.off=10.dur=-5.pub=-3 => 2
    close.comp=false.skip=0.off=10.dur=-5.pub=nan => 2
    close.comp=false.skip=0.off=10.dur=-5.pub=inf => 2
    close.comp=false.skip=0.off=10.dur=-5.pub=2.5 => 2
    close.comp=false.skip=0.off=10.dur=1000000000.pub=0 => 10
    close.comp=false.skip=0.off=10.dur=1000000000.pub=1 => 10
    close.comp=false.skip=0.off=10.dur=1000000000.pub=5 => 10
    close.comp=false.skip=0.off=10.dur=1000000000.pub=100 => 10
    close.comp=false.skip=0.off=10.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=0.off=10.dur=1000000000.pub=nan => 10
    close.comp=false.skip=0.off=10.dur=1000000000.pub=inf => 10
    close.comp=false.skip=0.off=10.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=0.off=10.dur=2.5.pub=0 => 2
    close.comp=false.skip=0.off=10.dur=2.5.pub=1 => 2
    close.comp=false.skip=0.off=10.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=0.off=10.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=0.off=10.dur=2.5.pub=-3 => 2
    close.comp=false.skip=0.off=10.dur=2.5.pub=nan => nan
    close.comp=false.skip=0.off=10.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=0.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=0.off=10.dur=nan.pub=0 => 2
    close.comp=false.skip=0.off=10.dur=nan.pub=1 => 2
    close.comp=false.skip=0.off=10.dur=nan.pub=5 => 5
    close.comp=false.skip=0.off=10.dur=nan.pub=100 => 30
    close.comp=false.skip=0.off=10.dur=nan.pub=-3 => 2
    close.comp=false.skip=0.off=10.dur=nan.pub=nan => nan
    close.comp=false.skip=0.off=10.dur=nan.pub=inf => 30
    close.comp=false.skip=0.off=10.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=0.off=10.dur=inf.pub=0 => 10
    close.comp=false.skip=0.off=10.dur=inf.pub=1 => 10
    close.comp=false.skip=0.off=10.dur=inf.pub=5 => 10
    close.comp=false.skip=0.off=10.dur=inf.pub=100 => 10
    close.comp=false.skip=0.off=10.dur=inf.pub=-3 => 10
    close.comp=false.skip=0.off=10.dur=inf.pub=nan => 10
    close.comp=false.skip=0.off=10.dur=inf.pub=inf => 10
    close.comp=false.skip=0.off=10.dur=inf.pub=2.5 => 10
    close.comp=false.skip=5.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=1 => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=100 => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=-3 => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=inf => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=2.5 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=1 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=100 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=-3 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=inf => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=2.5 => 2
    close.comp=false.skip=5.off=nil.dur=10.pub=0 => 5
    close.comp=false.skip=5.off=nil.dur=10.pub=1 => 5
    close.comp=false.skip=5.off=nil.dur=10.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=10.pub=100 => 5
    close.comp=false.skip=5.off=nil.dur=10.pub=-3 => 5
    close.comp=false.skip=5.off=nil.dur=10.pub=nan => 5
    close.comp=false.skip=5.off=nil.dur=10.pub=inf => 5
    close.comp=false.skip=5.off=nil.dur=10.pub=2.5 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=1 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=100 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=-3 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=inf => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=2.5 => 5
    close.comp=false.skip=5.off=nil.dur=-5.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=-5.pub=1 => 2
    close.comp=false.skip=5.off=nil.dur=-5.pub=5 => 2
    close.comp=false.skip=5.off=nil.dur=-5.pub=100 => 2
    close.comp=false.skip=5.off=nil.dur=-5.pub=-3 => 2
    close.comp=false.skip=5.off=nil.dur=-5.pub=nan => 2
    close.comp=false.skip=5.off=nil.dur=-5.pub=inf => 2
    close.comp=false.skip=5.off=nil.dur=-5.pub=2.5 => 2
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=0 => 5
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=1 => 5
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=100 => 5
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=-3 => 5
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=nan => 5
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=inf => 5
    close.comp=false.skip=5.off=nil.dur=1000000000.pub=2.5 => 5
    close.comp=false.skip=5.off=nil.dur=2.5.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=2.5.pub=1 => 2
    close.comp=false.skip=5.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=5.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=5.off=nil.dur=2.5.pub=-3 => 2
    close.comp=false.skip=5.off=nil.dur=2.5.pub=nan => nan
    close.comp=false.skip=5.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=5.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=5.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=nan.pub=1 => 2
    close.comp=false.skip=5.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=nan.pub=100 => 30
    close.comp=false.skip=5.off=nil.dur=nan.pub=-3 => 2
    close.comp=false.skip=5.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=nil.dur=nan.pub=inf => 30
    close.comp=false.skip=5.off=nil.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=5.off=nil.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=1 => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=100 => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=-3 => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=inf => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=2.5 => 5
    close.comp=false.skip=5.off=0.dur=nil.pub=0 => 0
    close.comp=false.skip=5.off=0.dur=nil.pub=1 => 0
    close.comp=false.skip=5.off=0.dur=nil.pub=5 => 0
    close.comp=false.skip=5.off=0.dur=nil.pub=100 => 0
    close.comp=false.skip=5.off=0.dur=nil.pub=-3 => 0
    close.comp=false.skip=5.off=0.dur=nil.pub=nan => 0
    close.comp=false.skip=5.off=0.dur=nil.pub=inf => 0
    close.comp=false.skip=5.off=0.dur=nil.pub=2.5 => 0
    close.comp=false.skip=5.off=0.dur=0.pub=0 => 0
    close.comp=false.skip=5.off=0.dur=0.pub=1 => 0
    close.comp=false.skip=5.off=0.dur=0.pub=5 => 0
    close.comp=false.skip=5.off=0.dur=0.pub=100 => 0
    close.comp=false.skip=5.off=0.dur=0.pub=-3 => 0
    close.comp=false.skip=5.off=0.dur=0.pub=nan => 0
    close.comp=false.skip=5.off=0.dur=0.pub=inf => 0
    close.comp=false.skip=5.off=0.dur=0.pub=2.5 => 0
    close.comp=false.skip=5.off=0.dur=10.pub=0 => 5
    close.comp=false.skip=5.off=0.dur=10.pub=1 => 5
    close.comp=false.skip=5.off=0.dur=10.pub=5 => 5
    close.comp=false.skip=5.off=0.dur=10.pub=100 => 5
    close.comp=false.skip=5.off=0.dur=10.pub=-3 => 5
    close.comp=false.skip=5.off=0.dur=10.pub=nan => 5
    close.comp=false.skip=5.off=0.dur=10.pub=inf => 5
    close.comp=false.skip=5.off=0.dur=10.pub=2.5 => 5
    close.comp=false.skip=5.off=0.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=0.dur=60.pub=1 => 5
    close.comp=false.skip=5.off=0.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=0.dur=60.pub=100 => 5
    close.comp=false.skip=5.off=0.dur=60.pub=-3 => 5
    close.comp=false.skip=5.off=0.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=0.dur=60.pub=inf => 5
    close.comp=false.skip=5.off=0.dur=60.pub=2.5 => 5
    close.comp=false.skip=5.off=0.dur=-5.pub=0 => 2
    close.comp=false.skip=5.off=0.dur=-5.pub=1 => 2
    close.comp=false.skip=5.off=0.dur=-5.pub=5 => 2
    close.comp=false.skip=5.off=0.dur=-5.pub=100 => 2
    close.comp=false.skip=5.off=0.dur=-5.pub=-3 => 2
    close.comp=false.skip=5.off=0.dur=-5.pub=nan => 2
    close.comp=false.skip=5.off=0.dur=-5.pub=inf => 2
    close.comp=false.skip=5.off=0.dur=-5.pub=2.5 => 2
    close.comp=false.skip=5.off=0.dur=1000000000.pub=0 => 5
    close.comp=false.skip=5.off=0.dur=1000000000.pub=1 => 5
    close.comp=false.skip=5.off=0.dur=1000000000.pub=5 => 5
    close.comp=false.skip=5.off=0.dur=1000000000.pub=100 => 5
    close.comp=false.skip=5.off=0.dur=1000000000.pub=-3 => 5
    close.comp=false.skip=5.off=0.dur=1000000000.pub=nan => 5
    close.comp=false.skip=5.off=0.dur=1000000000.pub=inf => 5
    close.comp=false.skip=5.off=0.dur=1000000000.pub=2.5 => 5
    close.comp=false.skip=5.off=0.dur=2.5.pub=0 => 0
    close.comp=false.skip=5.off=0.dur=2.5.pub=1 => 0
    close.comp=false.skip=5.off=0.dur=2.5.pub=5 => 0
    close.comp=false.skip=5.off=0.dur=2.5.pub=100 => 0
    close.comp=false.skip=5.off=0.dur=2.5.pub=-3 => 0
    close.comp=false.skip=5.off=0.dur=2.5.pub=nan => 0
    close.comp=false.skip=5.off=0.dur=2.5.pub=inf => 0
    close.comp=false.skip=5.off=0.dur=2.5.pub=2.5 => 0
    close.comp=false.skip=5.off=0.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=0.dur=nan.pub=1 => 2
    close.comp=false.skip=5.off=0.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=0.dur=nan.pub=100 => 30
    close.comp=false.skip=5.off=0.dur=nan.pub=-3 => 2
    close.comp=false.skip=5.off=0.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=0.dur=nan.pub=inf => 30
    close.comp=false.skip=5.off=0.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=5.off=0.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=0.dur=inf.pub=1 => 5
    close.comp=false.skip=5.off=0.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=0.dur=inf.pub=100 => 5
    close.comp=false.skip=5.off=0.dur=inf.pub=-3 => 5
    close.comp=false.skip=5.off=0.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=0.dur=inf.pub=inf => 5
    close.comp=false.skip=5.off=0.dur=inf.pub=2.5 => 5
    close.comp=false.skip=5.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=1 => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=100 => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=-3 => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=inf => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=2.5 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=1 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=100 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=-3 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=5.off=4.dur=0.pub=inf => 2
    close.comp=false.skip=5.off=4.dur=0.pub=2.5 => 2
    close.comp=false.skip=5.off=4.dur=10.pub=0 => 5
    close.comp=false.skip=5.off=4.dur=10.pub=1 => 5
    close.comp=false.skip=5.off=4.dur=10.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=10.pub=100 => 5
    close.comp=false.skip=5.off=4.dur=10.pub=-3 => 5
    close.comp=false.skip=5.off=4.dur=10.pub=nan => 5
    close.comp=false.skip=5.off=4.dur=10.pub=inf => 5
    close.comp=false.skip=5.off=4.dur=10.pub=2.5 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=1 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=100 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=-3 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=4.dur=60.pub=inf => 5
    close.comp=false.skip=5.off=4.dur=60.pub=2.5 => 5
    close.comp=false.skip=5.off=4.dur=-5.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=-5.pub=1 => 2
    close.comp=false.skip=5.off=4.dur=-5.pub=5 => 2
    close.comp=false.skip=5.off=4.dur=-5.pub=100 => 2
    close.comp=false.skip=5.off=4.dur=-5.pub=-3 => 2
    close.comp=false.skip=5.off=4.dur=-5.pub=nan => 2
    close.comp=false.skip=5.off=4.dur=-5.pub=inf => 2
    close.comp=false.skip=5.off=4.dur=-5.pub=2.5 => 2
    close.comp=false.skip=5.off=4.dur=1000000000.pub=0 => 5
    close.comp=false.skip=5.off=4.dur=1000000000.pub=1 => 5
    close.comp=false.skip=5.off=4.dur=1000000000.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=1000000000.pub=100 => 5
    close.comp=false.skip=5.off=4.dur=1000000000.pub=-3 => 5
    close.comp=false.skip=5.off=4.dur=1000000000.pub=nan => 5
    close.comp=false.skip=5.off=4.dur=1000000000.pub=inf => 5
    close.comp=false.skip=5.off=4.dur=1000000000.pub=2.5 => 5
    close.comp=false.skip=5.off=4.dur=2.5.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=2.5.pub=1 => 2
    close.comp=false.skip=5.off=4.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=5.off=4.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=5.off=4.dur=2.5.pub=-3 => 2
    close.comp=false.skip=5.off=4.dur=2.5.pub=nan => nan
    close.comp=false.skip=5.off=4.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=5.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=5.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=nan.pub=1 => 2
    close.comp=false.skip=5.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=nan.pub=100 => 30
    close.comp=false.skip=5.off=4.dur=nan.pub=-3 => 2
    close.comp=false.skip=5.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=4.dur=nan.pub=inf => 30
    close.comp=false.skip=5.off=4.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=5.off=4.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=1 => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=100 => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=-3 => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=inf => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=2.5 => 5
    close.comp=false.skip=5.off=20.dur=nil.pub=0 => 2
    close.comp=false.skip=5.off=20.dur=nil.pub=1 => 2
    close.comp=false.skip=5.off=20.dur=nil.pub=5 => 2
    close.comp=false.skip=5.off=20.dur=nil.pub=100 => 2
    close.comp=false.skip=5.off=20.dur=nil.pub=-3 => 2
    close.comp=false.skip=5.off=20.dur=nil.pub=nan => 2
    close.comp=false.skip=5.off=20.dur=nil.pub=inf => 2
    close.comp=false.skip=5.off=20.dur=nil.pub=2.5 => 2
    close.comp=false.skip=5.off=20.dur=0.pub=0 => 2
    close.comp=false.skip=5.off=20.dur=0.pub=1 => 2
    close.comp=false.skip=5.off=20.dur=0.pub=5 => 2
    close.comp=false.skip=5.off=20.dur=0.pub=100 => 2
    close.comp=false.skip=5.off=20.dur=0.pub=-3 => 2
    close.comp=false.skip=5.off=20.dur=0.pub=nan => 2
    close.comp=false.skip=5.off=20.dur=0.pub=inf => 2
    close.comp=false.skip=5.off=20.dur=0.pub=2.5 => 2
    close.comp=false.skip=5.off=20.dur=10.pub=0 => 5
    close.comp=false.skip=5.off=20.dur=10.pub=1 => 5
    close.comp=false.skip=5.off=20.dur=10.pub=5 => 5
    close.comp=false.skip=5.off=20.dur=10.pub=100 => 5
    close.comp=false.skip=5.off=20.dur=10.pub=-3 => 5
    close.comp=false.skip=5.off=20.dur=10.pub=nan => 5
    close.comp=false.skip=5.off=20.dur=10.pub=inf => 5
    close.comp=false.skip=5.off=20.dur=10.pub=2.5 => 5
    close.comp=false.skip=5.off=20.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=20.dur=60.pub=1 => 5
    close.comp=false.skip=5.off=20.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=20.dur=60.pub=100 => 5
    close.comp=false.skip=5.off=20.dur=60.pub=-3 => 5
    close.comp=false.skip=5.off=20.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=20.dur=60.pub=inf => 5
    close.comp=false.skip=5.off=20.dur=60.pub=2.5 => 5
    close.comp=false.skip=5.off=20.dur=-5.pub=0 => 2
    close.comp=false.skip=5.off=20.dur=-5.pub=1 => 2
    close.comp=false.skip=5.off=20.dur=-5.pub=5 => 2
    close.comp=false.skip=5.off=20.dur=-5.pub=100 => 2
    close.comp=false.skip=5.off=20.dur=-5.pub=-3 => 2
    close.comp=false.skip=5.off=20.dur=-5.pub=nan => 2
    close.comp=false.skip=5.off=20.dur=-5.pub=inf => 2
    close.comp=false.skip=5.off=20.dur=-5.pub=2.5 => 2
    close.comp=false.skip=5.off=20.dur=1000000000.pub=0 => 5
    close.comp=false.skip=5.off=20.dur=1000000000.pub=1 => 5
    close.comp=false.skip=5.off=20.dur=1000000000.pub=5 => 5
    close.comp=false.skip=5.off=20.dur=1000000000.pub=100 => 5
    close.comp=false.skip=5.off=20.dur=1000000000.pub=-3 => 5
    close.comp=false.skip=5.off=20.dur=1000000000.pub=nan => 5
    close.comp=false.skip=5.off=20.dur=1000000000.pub=inf => 5
    close.comp=false.skip=5.off=20.dur=1000000000.pub=2.5 => 5
    close.comp=false.skip=5.off=20.dur=2.5.pub=0 => 2
    close.comp=false.skip=5.off=20.dur=2.5.pub=1 => 2
    close.comp=false.skip=5.off=20.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=5.off=20.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=5.off=20.dur=2.5.pub=-3 => 2
    close.comp=false.skip=5.off=20.dur=2.5.pub=nan => nan
    close.comp=false.skip=5.off=20.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=5.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=5.off=20.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=20.dur=nan.pub=1 => 2
    close.comp=false.skip=5.off=20.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=20.dur=nan.pub=100 => 30
    close.comp=false.skip=5.off=20.dur=nan.pub=-3 => 2
    close.comp=false.skip=5.off=20.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=20.dur=nan.pub=inf => 30
    close.comp=false.skip=5.off=20.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=5.off=20.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=20.dur=inf.pub=1 => 5
    close.comp=false.skip=5.off=20.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=20.dur=inf.pub=100 => 5
    close.comp=false.skip=5.off=20.dur=inf.pub=-3 => 5
    close.comp=false.skip=5.off=20.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=20.dur=inf.pub=inf => 5
    close.comp=false.skip=5.off=20.dur=inf.pub=2.5 => 5
    close.comp=false.skip=5.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=1 => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=100 => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=-3 => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=inf => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=2.5 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=1 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=100 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=-3 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=inf => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=2.5 => -1
    close.comp=false.skip=5.off=-1.dur=10.pub=0 => 5
    close.comp=false.skip=5.off=-1.dur=10.pub=1 => 5
    close.comp=false.skip=5.off=-1.dur=10.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=10.pub=100 => 5
    close.comp=false.skip=5.off=-1.dur=10.pub=-3 => 5
    close.comp=false.skip=5.off=-1.dur=10.pub=nan => 5
    close.comp=false.skip=5.off=-1.dur=10.pub=inf => 5
    close.comp=false.skip=5.off=-1.dur=10.pub=2.5 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=1 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=100 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=-3 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=inf => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=2.5 => 5
    close.comp=false.skip=5.off=-1.dur=-5.pub=0 => 2
    close.comp=false.skip=5.off=-1.dur=-5.pub=1 => 2
    close.comp=false.skip=5.off=-1.dur=-5.pub=5 => 2
    close.comp=false.skip=5.off=-1.dur=-5.pub=100 => 2
    close.comp=false.skip=5.off=-1.dur=-5.pub=-3 => 2
    close.comp=false.skip=5.off=-1.dur=-5.pub=nan => 2
    close.comp=false.skip=5.off=-1.dur=-5.pub=inf => 2
    close.comp=false.skip=5.off=-1.dur=-5.pub=2.5 => 2
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=0 => 5
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=1 => 5
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=100 => 5
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=-3 => 5
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=nan => 5
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=inf => 5
    close.comp=false.skip=5.off=-1.dur=1000000000.pub=2.5 => 5
    close.comp=false.skip=5.off=-1.dur=2.5.pub=0 => -1
    close.comp=false.skip=5.off=-1.dur=2.5.pub=1 => -1
    close.comp=false.skip=5.off=-1.dur=2.5.pub=5 => -1
    close.comp=false.skip=5.off=-1.dur=2.5.pub=100 => -1
    close.comp=false.skip=5.off=-1.dur=2.5.pub=-3 => -1
    close.comp=false.skip=5.off=-1.dur=2.5.pub=nan => -1
    close.comp=false.skip=5.off=-1.dur=2.5.pub=inf => -1
    close.comp=false.skip=5.off=-1.dur=2.5.pub=2.5 => -1
    close.comp=false.skip=5.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=-1.dur=nan.pub=1 => 2
    close.comp=false.skip=5.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=nan.pub=100 => 30
    close.comp=false.skip=5.off=-1.dur=nan.pub=-3 => 2
    close.comp=false.skip=5.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=-1.dur=nan.pub=inf => 30
    close.comp=false.skip=5.off=-1.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=5.off=-1.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=1 => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=100 => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=-3 => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=inf => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=2.5 => 5
    close.comp=false.skip=5.off=10.dur=nil.pub=0 => 2
    close.comp=false.skip=5.off=10.dur=nil.pub=1 => 2
    close.comp=false.skip=5.off=10.dur=nil.pub=5 => 2
    close.comp=false.skip=5.off=10.dur=nil.pub=100 => 2
    close.comp=false.skip=5.off=10.dur=nil.pub=-3 => 2
    close.comp=false.skip=5.off=10.dur=nil.pub=nan => 2
    close.comp=false.skip=5.off=10.dur=nil.pub=inf => 2
    close.comp=false.skip=5.off=10.dur=nil.pub=2.5 => 2
    close.comp=false.skip=5.off=10.dur=0.pub=0 => 2
    close.comp=false.skip=5.off=10.dur=0.pub=1 => 2
    close.comp=false.skip=5.off=10.dur=0.pub=5 => 2
    close.comp=false.skip=5.off=10.dur=0.pub=100 => 2
    close.comp=false.skip=5.off=10.dur=0.pub=-3 => 2
    close.comp=false.skip=5.off=10.dur=0.pub=nan => 2
    close.comp=false.skip=5.off=10.dur=0.pub=inf => 2
    close.comp=false.skip=5.off=10.dur=0.pub=2.5 => 2
    close.comp=false.skip=5.off=10.dur=10.pub=0 => 5
    close.comp=false.skip=5.off=10.dur=10.pub=1 => 5
    close.comp=false.skip=5.off=10.dur=10.pub=5 => 5
    close.comp=false.skip=5.off=10.dur=10.pub=100 => 5
    close.comp=false.skip=5.off=10.dur=10.pub=-3 => 5
    close.comp=false.skip=5.off=10.dur=10.pub=nan => 5
    close.comp=false.skip=5.off=10.dur=10.pub=inf => 5
    close.comp=false.skip=5.off=10.dur=10.pub=2.5 => 5
    close.comp=false.skip=5.off=10.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=10.dur=60.pub=1 => 5
    close.comp=false.skip=5.off=10.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=10.dur=60.pub=100 => 5
    close.comp=false.skip=5.off=10.dur=60.pub=-3 => 5
    close.comp=false.skip=5.off=10.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=10.dur=60.pub=inf => 5
    close.comp=false.skip=5.off=10.dur=60.pub=2.5 => 5
    close.comp=false.skip=5.off=10.dur=-5.pub=0 => 2
    close.comp=false.skip=5.off=10.dur=-5.pub=1 => 2
    close.comp=false.skip=5.off=10.dur=-5.pub=5 => 2
    close.comp=false.skip=5.off=10.dur=-5.pub=100 => 2
    close.comp=false.skip=5.off=10.dur=-5.pub=-3 => 2
    close.comp=false.skip=5.off=10.dur=-5.pub=nan => 2
    close.comp=false.skip=5.off=10.dur=-5.pub=inf => 2
    close.comp=false.skip=5.off=10.dur=-5.pub=2.5 => 2
    close.comp=false.skip=5.off=10.dur=1000000000.pub=0 => 5
    close.comp=false.skip=5.off=10.dur=1000000000.pub=1 => 5
    close.comp=false.skip=5.off=10.dur=1000000000.pub=5 => 5
    close.comp=false.skip=5.off=10.dur=1000000000.pub=100 => 5
    close.comp=false.skip=5.off=10.dur=1000000000.pub=-3 => 5
    close.comp=false.skip=5.off=10.dur=1000000000.pub=nan => 5
    close.comp=false.skip=5.off=10.dur=1000000000.pub=inf => 5
    close.comp=false.skip=5.off=10.dur=1000000000.pub=2.5 => 5
    close.comp=false.skip=5.off=10.dur=2.5.pub=0 => 2
    close.comp=false.skip=5.off=10.dur=2.5.pub=1 => 2
    close.comp=false.skip=5.off=10.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=5.off=10.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=5.off=10.dur=2.5.pub=-3 => 2
    close.comp=false.skip=5.off=10.dur=2.5.pub=nan => nan
    close.comp=false.skip=5.off=10.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=5.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=5.off=10.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=10.dur=nan.pub=1 => 2
    close.comp=false.skip=5.off=10.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=10.dur=nan.pub=100 => 30
    close.comp=false.skip=5.off=10.dur=nan.pub=-3 => 2
    close.comp=false.skip=5.off=10.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=10.dur=nan.pub=inf => 30
    close.comp=false.skip=5.off=10.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=5.off=10.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=10.dur=inf.pub=1 => 5
    close.comp=false.skip=5.off=10.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=10.dur=inf.pub=100 => 5
    close.comp=false.skip=5.off=10.dur=inf.pub=-3 => 5
    close.comp=false.skip=5.off=10.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=10.dur=inf.pub=inf => 5
    close.comp=false.skip=5.off=10.dur=inf.pub=2.5 => 5
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=1 => 2
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=100 => 2
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=-3 => 2
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=inf => 2
    close.comp=false.skip=1000000.off=nil.dur=nil.pub=2.5 => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=1 => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=100 => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=-3 => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=inf => 2
    close.comp=false.skip=1000000.off=nil.dur=0.pub=2.5 => 2
    close.comp=false.skip=1000000.off=nil.dur=10.pub=0 => 2
    close.comp=false.skip=1000000.off=nil.dur=10.pub=1 => 2
    close.comp=false.skip=1000000.off=nil.dur=10.pub=5 => 5
    close.comp=false.skip=1000000.off=nil.dur=10.pub=100 => 10
    close.comp=false.skip=1000000.off=nil.dur=10.pub=-3 => 2
    close.comp=false.skip=1000000.off=nil.dur=10.pub=nan => nan
    close.comp=false.skip=1000000.off=nil.dur=10.pub=inf => 10
    close.comp=false.skip=1000000.off=nil.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=nil.dur=60.pub=0 => 2
    close.comp=false.skip=1000000.off=nil.dur=60.pub=1 => 2
    close.comp=false.skip=1000000.off=nil.dur=60.pub=5 => 5
    close.comp=false.skip=1000000.off=nil.dur=60.pub=100 => 30
    close.comp=false.skip=1000000.off=nil.dur=60.pub=-3 => 2
    close.comp=false.skip=1000000.off=nil.dur=60.pub=nan => nan
    close.comp=false.skip=1000000.off=nil.dur=60.pub=inf => 30
    close.comp=false.skip=1000000.off=nil.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=0 => 2
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=1 => 2
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=5 => 2
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=100 => 2
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=-3 => 2
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=nan => 2
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=inf => 2
    close.comp=false.skip=1000000.off=nil.dur=-5.pub=2.5 => 2
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=0 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=1 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=5 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=100 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=nan => 1000000
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=inf => 1000000
    close.comp=false.skip=1000000.off=nil.dur=1000000000.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=0 => 2
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=1 => 2
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=-3 => 2
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=nan => nan
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=1000000.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=1 => 2
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=100 => 30
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=-3 => 2
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=inf => 30
    close.comp=false.skip=1000000.off=nil.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=0 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=1 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=5 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=100 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=nan => 1000000
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=inf => 1000000
    close.comp=false.skip=1000000.off=nil.dur=inf.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=0.dur=nil.pub=0 => 0
    close.comp=false.skip=1000000.off=0.dur=nil.pub=1 => 0
    close.comp=false.skip=1000000.off=0.dur=nil.pub=5 => 0
    close.comp=false.skip=1000000.off=0.dur=nil.pub=100 => 0
    close.comp=false.skip=1000000.off=0.dur=nil.pub=-3 => 0
    close.comp=false.skip=1000000.off=0.dur=nil.pub=nan => 0
    close.comp=false.skip=1000000.off=0.dur=nil.pub=inf => 0
    close.comp=false.skip=1000000.off=0.dur=nil.pub=2.5 => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=0 => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=1 => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=5 => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=100 => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=-3 => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=nan => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=inf => 0
    close.comp=false.skip=1000000.off=0.dur=0.pub=2.5 => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=0 => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=1 => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=5 => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=100 => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=-3 => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=nan => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=inf => 0
    close.comp=false.skip=1000000.off=0.dur=10.pub=2.5 => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=0 => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=1 => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=5 => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=100 => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=-3 => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=nan => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=inf => 0
    close.comp=false.skip=1000000.off=0.dur=60.pub=2.5 => 0
    close.comp=false.skip=1000000.off=0.dur=-5.pub=0 => 2
    close.comp=false.skip=1000000.off=0.dur=-5.pub=1 => 2
    close.comp=false.skip=1000000.off=0.dur=-5.pub=5 => 2
    close.comp=false.skip=1000000.off=0.dur=-5.pub=100 => 2
    close.comp=false.skip=1000000.off=0.dur=-5.pub=-3 => 2
    close.comp=false.skip=1000000.off=0.dur=-5.pub=nan => 2
    close.comp=false.skip=1000000.off=0.dur=-5.pub=inf => 2
    close.comp=false.skip=1000000.off=0.dur=-5.pub=2.5 => 2
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=0 => 1000000
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=1 => 1000000
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=5 => 1000000
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=100 => 1000000
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=nan => 1000000
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=inf => 1000000
    close.comp=false.skip=1000000.off=0.dur=1000000000.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=0 => 0
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=1 => 0
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=5 => 0
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=100 => 0
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=-3 => 0
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=nan => 0
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=inf => 0
    close.comp=false.skip=1000000.off=0.dur=2.5.pub=2.5 => 0
    close.comp=false.skip=1000000.off=0.dur=nan.pub=0 => 2
    close.comp=false.skip=1000000.off=0.dur=nan.pub=1 => 2
    close.comp=false.skip=1000000.off=0.dur=nan.pub=5 => 5
    close.comp=false.skip=1000000.off=0.dur=nan.pub=100 => 30
    close.comp=false.skip=1000000.off=0.dur=nan.pub=-3 => 2
    close.comp=false.skip=1000000.off=0.dur=nan.pub=nan => nan
    close.comp=false.skip=1000000.off=0.dur=nan.pub=inf => 30
    close.comp=false.skip=1000000.off=0.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=0.dur=inf.pub=0 => 1000000
    close.comp=false.skip=1000000.off=0.dur=inf.pub=1 => 1000000
    close.comp=false.skip=1000000.off=0.dur=inf.pub=5 => 1000000
    close.comp=false.skip=1000000.off=0.dur=inf.pub=100 => 1000000
    close.comp=false.skip=1000000.off=0.dur=inf.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=0.dur=inf.pub=nan => 1000000
    close.comp=false.skip=1000000.off=0.dur=inf.pub=inf => 1000000
    close.comp=false.skip=1000000.off=0.dur=inf.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=1000000.off=4.dur=nil.pub=1 => 2
    close.comp=false.skip=1000000.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=1000000.off=4.dur=nil.pub=100 => 2
    close.comp=false.skip=1000000.off=4.dur=nil.pub=-3 => 2
    close.comp=false.skip=1000000.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=1000000.off=4.dur=nil.pub=inf => 2
    close.comp=false.skip=1000000.off=4.dur=nil.pub=2.5 => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=1 => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=100 => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=-3 => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=inf => 2
    close.comp=false.skip=1000000.off=4.dur=0.pub=2.5 => 2
    close.comp=false.skip=1000000.off=4.dur=10.pub=0 => 4
    close.comp=false.skip=1000000.off=4.dur=10.pub=1 => 4
    close.comp=false.skip=1000000.off=4.dur=10.pub=5 => 4
    close.comp=false.skip=1000000.off=4.dur=10.pub=100 => 4
    close.comp=false.skip=1000000.off=4.dur=10.pub=-3 => 4
    close.comp=false.skip=1000000.off=4.dur=10.pub=nan => 4
    close.comp=false.skip=1000000.off=4.dur=10.pub=inf => 4
    close.comp=false.skip=1000000.off=4.dur=10.pub=2.5 => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=0 => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=1 => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=5 => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=100 => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=-3 => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=nan => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=inf => 4
    close.comp=false.skip=1000000.off=4.dur=60.pub=2.5 => 4
    close.comp=false.skip=1000000.off=4.dur=-5.pub=0 => 2
    close.comp=false.skip=1000000.off=4.dur=-5.pub=1 => 2
    close.comp=false.skip=1000000.off=4.dur=-5.pub=5 => 2
    close.comp=false.skip=1000000.off=4.dur=-5.pub=100 => 2
    close.comp=false.skip=1000000.off=4.dur=-5.pub=-3 => 2
    close.comp=false.skip=1000000.off=4.dur=-5.pub=nan => 2
    close.comp=false.skip=1000000.off=4.dur=-5.pub=inf => 2
    close.comp=false.skip=1000000.off=4.dur=-5.pub=2.5 => 2
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=0 => 1000000
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=1 => 1000000
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=5 => 1000000
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=100 => 1000000
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=nan => 1000000
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=inf => 1000000
    close.comp=false.skip=1000000.off=4.dur=1000000000.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=0 => 2
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=1 => 2
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=-3 => 2
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=nan => nan
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=1000000.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=1000000.off=4.dur=nan.pub=1 => 2
    close.comp=false.skip=1000000.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=1000000.off=4.dur=nan.pub=100 => 30
    close.comp=false.skip=1000000.off=4.dur=nan.pub=-3 => 2
    close.comp=false.skip=1000000.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=1000000.off=4.dur=nan.pub=inf => 30
    close.comp=false.skip=1000000.off=4.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=4.dur=inf.pub=0 => 1000000
    close.comp=false.skip=1000000.off=4.dur=inf.pub=1 => 1000000
    close.comp=false.skip=1000000.off=4.dur=inf.pub=5 => 1000000
    close.comp=false.skip=1000000.off=4.dur=inf.pub=100 => 1000000
    close.comp=false.skip=1000000.off=4.dur=inf.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=4.dur=inf.pub=nan => 1000000
    close.comp=false.skip=1000000.off=4.dur=inf.pub=inf => 1000000
    close.comp=false.skip=1000000.off=4.dur=inf.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=20.dur=nil.pub=0 => 2
    close.comp=false.skip=1000000.off=20.dur=nil.pub=1 => 2
    close.comp=false.skip=1000000.off=20.dur=nil.pub=5 => 2
    close.comp=false.skip=1000000.off=20.dur=nil.pub=100 => 2
    close.comp=false.skip=1000000.off=20.dur=nil.pub=-3 => 2
    close.comp=false.skip=1000000.off=20.dur=nil.pub=nan => 2
    close.comp=false.skip=1000000.off=20.dur=nil.pub=inf => 2
    close.comp=false.skip=1000000.off=20.dur=nil.pub=2.5 => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=0 => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=1 => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=5 => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=100 => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=-3 => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=nan => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=inf => 2
    close.comp=false.skip=1000000.off=20.dur=0.pub=2.5 => 2
    close.comp=false.skip=1000000.off=20.dur=10.pub=0 => 2
    close.comp=false.skip=1000000.off=20.dur=10.pub=1 => 2
    close.comp=false.skip=1000000.off=20.dur=10.pub=5 => 5
    close.comp=false.skip=1000000.off=20.dur=10.pub=100 => 10
    close.comp=false.skip=1000000.off=20.dur=10.pub=-3 => 2
    close.comp=false.skip=1000000.off=20.dur=10.pub=nan => nan
    close.comp=false.skip=1000000.off=20.dur=10.pub=inf => 10
    close.comp=false.skip=1000000.off=20.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=20.dur=60.pub=0 => 20
    close.comp=false.skip=1000000.off=20.dur=60.pub=1 => 20
    close.comp=false.skip=1000000.off=20.dur=60.pub=5 => 20
    close.comp=false.skip=1000000.off=20.dur=60.pub=100 => 20
    close.comp=false.skip=1000000.off=20.dur=60.pub=-3 => 20
    close.comp=false.skip=1000000.off=20.dur=60.pub=nan => 20
    close.comp=false.skip=1000000.off=20.dur=60.pub=inf => 20
    close.comp=false.skip=1000000.off=20.dur=60.pub=2.5 => 20
    close.comp=false.skip=1000000.off=20.dur=-5.pub=0 => 2
    close.comp=false.skip=1000000.off=20.dur=-5.pub=1 => 2
    close.comp=false.skip=1000000.off=20.dur=-5.pub=5 => 2
    close.comp=false.skip=1000000.off=20.dur=-5.pub=100 => 2
    close.comp=false.skip=1000000.off=20.dur=-5.pub=-3 => 2
    close.comp=false.skip=1000000.off=20.dur=-5.pub=nan => 2
    close.comp=false.skip=1000000.off=20.dur=-5.pub=inf => 2
    close.comp=false.skip=1000000.off=20.dur=-5.pub=2.5 => 2
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=0 => 1000000
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=1 => 1000000
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=5 => 1000000
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=100 => 1000000
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=nan => 1000000
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=inf => 1000000
    close.comp=false.skip=1000000.off=20.dur=1000000000.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=0 => 2
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=1 => 2
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=-3 => 2
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=nan => nan
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=1000000.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=20.dur=nan.pub=0 => 2
    close.comp=false.skip=1000000.off=20.dur=nan.pub=1 => 2
    close.comp=false.skip=1000000.off=20.dur=nan.pub=5 => 5
    close.comp=false.skip=1000000.off=20.dur=nan.pub=100 => 30
    close.comp=false.skip=1000000.off=20.dur=nan.pub=-3 => 2
    close.comp=false.skip=1000000.off=20.dur=nan.pub=nan => nan
    close.comp=false.skip=1000000.off=20.dur=nan.pub=inf => 30
    close.comp=false.skip=1000000.off=20.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=20.dur=inf.pub=0 => 1000000
    close.comp=false.skip=1000000.off=20.dur=inf.pub=1 => 1000000
    close.comp=false.skip=1000000.off=20.dur=inf.pub=5 => 1000000
    close.comp=false.skip=1000000.off=20.dur=inf.pub=100 => 1000000
    close.comp=false.skip=1000000.off=20.dur=inf.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=20.dur=inf.pub=nan => 1000000
    close.comp=false.skip=1000000.off=20.dur=inf.pub=inf => 1000000
    close.comp=false.skip=1000000.off=20.dur=inf.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=1 => -1
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=100 => -1
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=-3 => -1
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=inf => -1
    close.comp=false.skip=1000000.off=-1.dur=nil.pub=2.5 => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=1 => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=100 => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=-3 => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=inf => -1
    close.comp=false.skip=1000000.off=-1.dur=0.pub=2.5 => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=0 => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=1 => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=5 => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=100 => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=-3 => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=nan => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=inf => -1
    close.comp=false.skip=1000000.off=-1.dur=10.pub=2.5 => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=0 => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=1 => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=5 => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=100 => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=-3 => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=nan => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=inf => -1
    close.comp=false.skip=1000000.off=-1.dur=60.pub=2.5 => -1
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=0 => 2
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=1 => 2
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=5 => 2
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=100 => 2
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=-3 => 2
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=nan => 2
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=inf => 2
    close.comp=false.skip=1000000.off=-1.dur=-5.pub=2.5 => 2
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=0 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=1 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=5 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=100 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=nan => 1000000
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=inf => 1000000
    close.comp=false.skip=1000000.off=-1.dur=1000000000.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=0 => -1
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=1 => -1
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=5 => -1
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=100 => -1
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=-3 => -1
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=nan => -1
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=inf => -1
    close.comp=false.skip=1000000.off=-1.dur=2.5.pub=2.5 => -1
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=1 => 2
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=100 => 30
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=-3 => 2
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=inf => 30
    close.comp=false.skip=1000000.off=-1.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=0 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=1 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=5 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=100 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=nan => 1000000
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=inf => 1000000
    close.comp=false.skip=1000000.off=-1.dur=inf.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=10.dur=nil.pub=0 => 2
    close.comp=false.skip=1000000.off=10.dur=nil.pub=1 => 2
    close.comp=false.skip=1000000.off=10.dur=nil.pub=5 => 2
    close.comp=false.skip=1000000.off=10.dur=nil.pub=100 => 2
    close.comp=false.skip=1000000.off=10.dur=nil.pub=-3 => 2
    close.comp=false.skip=1000000.off=10.dur=nil.pub=nan => 2
    close.comp=false.skip=1000000.off=10.dur=nil.pub=inf => 2
    close.comp=false.skip=1000000.off=10.dur=nil.pub=2.5 => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=0 => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=1 => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=5 => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=100 => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=-3 => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=nan => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=inf => 2
    close.comp=false.skip=1000000.off=10.dur=0.pub=2.5 => 2
    close.comp=false.skip=1000000.off=10.dur=10.pub=0 => 10
    close.comp=false.skip=1000000.off=10.dur=10.pub=1 => 10
    close.comp=false.skip=1000000.off=10.dur=10.pub=5 => 10
    close.comp=false.skip=1000000.off=10.dur=10.pub=100 => 10
    close.comp=false.skip=1000000.off=10.dur=10.pub=-3 => 10
    close.comp=false.skip=1000000.off=10.dur=10.pub=nan => 10
    close.comp=false.skip=1000000.off=10.dur=10.pub=inf => 10
    close.comp=false.skip=1000000.off=10.dur=10.pub=2.5 => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=0 => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=1 => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=5 => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=100 => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=-3 => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=nan => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=inf => 10
    close.comp=false.skip=1000000.off=10.dur=60.pub=2.5 => 10
    close.comp=false.skip=1000000.off=10.dur=-5.pub=0 => 2
    close.comp=false.skip=1000000.off=10.dur=-5.pub=1 => 2
    close.comp=false.skip=1000000.off=10.dur=-5.pub=5 => 2
    close.comp=false.skip=1000000.off=10.dur=-5.pub=100 => 2
    close.comp=false.skip=1000000.off=10.dur=-5.pub=-3 => 2
    close.comp=false.skip=1000000.off=10.dur=-5.pub=nan => 2
    close.comp=false.skip=1000000.off=10.dur=-5.pub=inf => 2
    close.comp=false.skip=1000000.off=10.dur=-5.pub=2.5 => 2
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=0 => 1000000
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=1 => 1000000
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=5 => 1000000
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=100 => 1000000
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=nan => 1000000
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=inf => 1000000
    close.comp=false.skip=1000000.off=10.dur=1000000000.pub=2.5 => 1000000
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=0 => 2
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=1 => 2
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=-3 => 2
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=nan => nan
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=1000000.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=10.dur=nan.pub=0 => 2
    close.comp=false.skip=1000000.off=10.dur=nan.pub=1 => 2
    close.comp=false.skip=1000000.off=10.dur=nan.pub=5 => 5
    close.comp=false.skip=1000000.off=10.dur=nan.pub=100 => 30
    close.comp=false.skip=1000000.off=10.dur=nan.pub=-3 => 2
    close.comp=false.skip=1000000.off=10.dur=nan.pub=nan => nan
    close.comp=false.skip=1000000.off=10.dur=nan.pub=inf => 30
    close.comp=false.skip=1000000.off=10.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=1000000.off=10.dur=inf.pub=0 => 1000000
    close.comp=false.skip=1000000.off=10.dur=inf.pub=1 => 1000000
    close.comp=false.skip=1000000.off=10.dur=inf.pub=5 => 1000000
    close.comp=false.skip=1000000.off=10.dur=inf.pub=100 => 1000000
    close.comp=false.skip=1000000.off=10.dur=inf.pub=-3 => 1000000
    close.comp=false.skip=1000000.off=10.dur=inf.pub=nan => 1000000
    close.comp=false.skip=1000000.off=10.dur=inf.pub=inf => 1000000
    close.comp=false.skip=1000000.off=10.dur=inf.pub=2.5 => 1000000
    close.comp=false.skip=-2.off=nil.dur=nil.pub=0 => -2
    close.comp=false.skip=-2.off=nil.dur=nil.pub=1 => -2
    close.comp=false.skip=-2.off=nil.dur=nil.pub=5 => -2
    close.comp=false.skip=-2.off=nil.dur=nil.pub=100 => -2
    close.comp=false.skip=-2.off=nil.dur=nil.pub=-3 => -2
    close.comp=false.skip=-2.off=nil.dur=nil.pub=nan => -2
    close.comp=false.skip=-2.off=nil.dur=nil.pub=inf => -2
    close.comp=false.skip=-2.off=nil.dur=nil.pub=2.5 => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=0 => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=1 => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=5 => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=100 => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=-3 => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=nan => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=inf => -2
    close.comp=false.skip=-2.off=nil.dur=0.pub=2.5 => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=0 => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=1 => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=5 => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=100 => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=-3 => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=nan => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=inf => -2
    close.comp=false.skip=-2.off=nil.dur=10.pub=2.5 => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=0 => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=1 => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=5 => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=100 => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=-3 => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=nan => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=inf => -2
    close.comp=false.skip=-2.off=nil.dur=60.pub=2.5 => -2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=0 => 2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=1 => 2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=5 => 2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=100 => 2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=-3 => 2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=nan => 2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=inf => 2
    close.comp=false.skip=-2.off=nil.dur=-5.pub=2.5 => 2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=0 => -2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=1 => -2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=5 => -2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=100 => -2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=-3 => -2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=nan => -2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=inf => -2
    close.comp=false.skip=-2.off=nil.dur=1000000000.pub=2.5 => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=0 => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=1 => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=5 => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=100 => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=-3 => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=nan => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=inf => -2
    close.comp=false.skip=-2.off=nil.dur=2.5.pub=2.5 => -2
    close.comp=false.skip=-2.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=-2.off=nil.dur=nan.pub=1 => 2
    close.comp=false.skip=-2.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=-2.off=nil.dur=nan.pub=100 => 30
    close.comp=false.skip=-2.off=nil.dur=nan.pub=-3 => 2
    close.comp=false.skip=-2.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=-2.off=nil.dur=nan.pub=inf => 30
    close.comp=false.skip=-2.off=nil.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=-2.off=nil.dur=inf.pub=0 => -2
    close.comp=false.skip=-2.off=nil.dur=inf.pub=1 => -2
    close.comp=false.skip=-2.off=nil.dur=inf.pub=5 => -2
    close.comp=false.skip=-2.off=nil.dur=inf.pub=100 => -2
    close.comp=false.skip=-2.off=nil.dur=inf.pub=-3 => -2
    close.comp=false.skip=-2.off=nil.dur=inf.pub=nan => -2
    close.comp=false.skip=-2.off=nil.dur=inf.pub=inf => -2
    close.comp=false.skip=-2.off=nil.dur=inf.pub=2.5 => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=0 => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=1 => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=5 => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=100 => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=-3 => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=nan => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=inf => -2
    close.comp=false.skip=-2.off=0.dur=nil.pub=2.5 => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=0 => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=1 => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=5 => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=100 => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=-3 => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=nan => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=inf => -2
    close.comp=false.skip=-2.off=0.dur=0.pub=2.5 => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=0 => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=1 => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=5 => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=100 => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=-3 => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=nan => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=inf => -2
    close.comp=false.skip=-2.off=0.dur=10.pub=2.5 => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=0 => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=1 => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=5 => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=100 => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=-3 => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=nan => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=inf => -2
    close.comp=false.skip=-2.off=0.dur=60.pub=2.5 => -2
    close.comp=false.skip=-2.off=0.dur=-5.pub=0 => 2
    close.comp=false.skip=-2.off=0.dur=-5.pub=1 => 2
    close.comp=false.skip=-2.off=0.dur=-5.pub=5 => 2
    close.comp=false.skip=-2.off=0.dur=-5.pub=100 => 2
    close.comp=false.skip=-2.off=0.dur=-5.pub=-3 => 2
    close.comp=false.skip=-2.off=0.dur=-5.pub=nan => 2
    close.comp=false.skip=-2.off=0.dur=-5.pub=inf => 2
    close.comp=false.skip=-2.off=0.dur=-5.pub=2.5 => 2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=0 => -2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=1 => -2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=5 => -2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=100 => -2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=-3 => -2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=nan => -2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=inf => -2
    close.comp=false.skip=-2.off=0.dur=1000000000.pub=2.5 => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=0 => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=1 => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=5 => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=100 => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=-3 => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=nan => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=inf => -2
    close.comp=false.skip=-2.off=0.dur=2.5.pub=2.5 => -2
    close.comp=false.skip=-2.off=0.dur=nan.pub=0 => 2
    close.comp=false.skip=-2.off=0.dur=nan.pub=1 => 2
    close.comp=false.skip=-2.off=0.dur=nan.pub=5 => 5
    close.comp=false.skip=-2.off=0.dur=nan.pub=100 => 30
    close.comp=false.skip=-2.off=0.dur=nan.pub=-3 => 2
    close.comp=false.skip=-2.off=0.dur=nan.pub=nan => nan
    close.comp=false.skip=-2.off=0.dur=nan.pub=inf => 30
    close.comp=false.skip=-2.off=0.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=-2.off=0.dur=inf.pub=0 => -2
    close.comp=false.skip=-2.off=0.dur=inf.pub=1 => -2
    close.comp=false.skip=-2.off=0.dur=inf.pub=5 => -2
    close.comp=false.skip=-2.off=0.dur=inf.pub=100 => -2
    close.comp=false.skip=-2.off=0.dur=inf.pub=-3 => -2
    close.comp=false.skip=-2.off=0.dur=inf.pub=nan => -2
    close.comp=false.skip=-2.off=0.dur=inf.pub=inf => -2
    close.comp=false.skip=-2.off=0.dur=inf.pub=2.5 => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=0 => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=1 => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=5 => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=100 => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=-3 => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=nan => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=inf => -2
    close.comp=false.skip=-2.off=4.dur=nil.pub=2.5 => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=0 => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=1 => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=5 => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=100 => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=-3 => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=nan => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=inf => -2
    close.comp=false.skip=-2.off=4.dur=0.pub=2.5 => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=0 => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=1 => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=5 => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=100 => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=-3 => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=nan => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=inf => -2
    close.comp=false.skip=-2.off=4.dur=10.pub=2.5 => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=0 => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=1 => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=5 => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=100 => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=-3 => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=nan => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=inf => -2
    close.comp=false.skip=-2.off=4.dur=60.pub=2.5 => -2
    close.comp=false.skip=-2.off=4.dur=-5.pub=0 => 2
    close.comp=false.skip=-2.off=4.dur=-5.pub=1 => 2
    close.comp=false.skip=-2.off=4.dur=-5.pub=5 => 2
    close.comp=false.skip=-2.off=4.dur=-5.pub=100 => 2
    close.comp=false.skip=-2.off=4.dur=-5.pub=-3 => 2
    close.comp=false.skip=-2.off=4.dur=-5.pub=nan => 2
    close.comp=false.skip=-2.off=4.dur=-5.pub=inf => 2
    close.comp=false.skip=-2.off=4.dur=-5.pub=2.5 => 2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=0 => -2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=1 => -2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=5 => -2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=100 => -2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=-3 => -2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=nan => -2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=inf => -2
    close.comp=false.skip=-2.off=4.dur=1000000000.pub=2.5 => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=0 => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=1 => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=5 => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=100 => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=-3 => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=nan => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=inf => -2
    close.comp=false.skip=-2.off=4.dur=2.5.pub=2.5 => -2
    close.comp=false.skip=-2.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=-2.off=4.dur=nan.pub=1 => 2
    close.comp=false.skip=-2.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=-2.off=4.dur=nan.pub=100 => 30
    close.comp=false.skip=-2.off=4.dur=nan.pub=-3 => 2
    close.comp=false.skip=-2.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=-2.off=4.dur=nan.pub=inf => 30
    close.comp=false.skip=-2.off=4.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=-2.off=4.dur=inf.pub=0 => -2
    close.comp=false.skip=-2.off=4.dur=inf.pub=1 => -2
    close.comp=false.skip=-2.off=4.dur=inf.pub=5 => -2
    close.comp=false.skip=-2.off=4.dur=inf.pub=100 => -2
    close.comp=false.skip=-2.off=4.dur=inf.pub=-3 => -2
    close.comp=false.skip=-2.off=4.dur=inf.pub=nan => -2
    close.comp=false.skip=-2.off=4.dur=inf.pub=inf => -2
    close.comp=false.skip=-2.off=4.dur=inf.pub=2.5 => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=0 => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=1 => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=5 => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=100 => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=-3 => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=nan => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=inf => -2
    close.comp=false.skip=-2.off=20.dur=nil.pub=2.5 => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=0 => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=1 => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=5 => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=100 => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=-3 => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=nan => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=inf => -2
    close.comp=false.skip=-2.off=20.dur=0.pub=2.5 => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=0 => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=1 => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=5 => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=100 => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=-3 => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=nan => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=inf => -2
    close.comp=false.skip=-2.off=20.dur=10.pub=2.5 => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=0 => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=1 => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=5 => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=100 => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=-3 => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=nan => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=inf => -2
    close.comp=false.skip=-2.off=20.dur=60.pub=2.5 => -2
    close.comp=false.skip=-2.off=20.dur=-5.pub=0 => 2
    close.comp=false.skip=-2.off=20.dur=-5.pub=1 => 2
    close.comp=false.skip=-2.off=20.dur=-5.pub=5 => 2
    close.comp=false.skip=-2.off=20.dur=-5.pub=100 => 2
    close.comp=false.skip=-2.off=20.dur=-5.pub=-3 => 2
    close.comp=false.skip=-2.off=20.dur=-5.pub=nan => 2
    close.comp=false.skip=-2.off=20.dur=-5.pub=inf => 2
    close.comp=false.skip=-2.off=20.dur=-5.pub=2.5 => 2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=0 => -2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=1 => -2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=5 => -2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=100 => -2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=-3 => -2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=nan => -2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=inf => -2
    close.comp=false.skip=-2.off=20.dur=1000000000.pub=2.5 => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=0 => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=1 => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=5 => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=100 => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=-3 => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=nan => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=inf => -2
    close.comp=false.skip=-2.off=20.dur=2.5.pub=2.5 => -2
    close.comp=false.skip=-2.off=20.dur=nan.pub=0 => 2
    close.comp=false.skip=-2.off=20.dur=nan.pub=1 => 2
    close.comp=false.skip=-2.off=20.dur=nan.pub=5 => 5
    close.comp=false.skip=-2.off=20.dur=nan.pub=100 => 30
    close.comp=false.skip=-2.off=20.dur=nan.pub=-3 => 2
    close.comp=false.skip=-2.off=20.dur=nan.pub=nan => nan
    close.comp=false.skip=-2.off=20.dur=nan.pub=inf => 30
    close.comp=false.skip=-2.off=20.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=-2.off=20.dur=inf.pub=0 => -2
    close.comp=false.skip=-2.off=20.dur=inf.pub=1 => -2
    close.comp=false.skip=-2.off=20.dur=inf.pub=5 => -2
    close.comp=false.skip=-2.off=20.dur=inf.pub=100 => -2
    close.comp=false.skip=-2.off=20.dur=inf.pub=-3 => -2
    close.comp=false.skip=-2.off=20.dur=inf.pub=nan => -2
    close.comp=false.skip=-2.off=20.dur=inf.pub=inf => -2
    close.comp=false.skip=-2.off=20.dur=inf.pub=2.5 => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=0 => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=1 => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=5 => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=100 => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=-3 => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=nan => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=inf => -2
    close.comp=false.skip=-2.off=-1.dur=nil.pub=2.5 => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=0 => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=1 => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=5 => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=100 => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=-3 => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=nan => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=inf => -2
    close.comp=false.skip=-2.off=-1.dur=0.pub=2.5 => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=0 => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=1 => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=5 => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=100 => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=-3 => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=nan => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=inf => -2
    close.comp=false.skip=-2.off=-1.dur=10.pub=2.5 => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=0 => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=1 => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=5 => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=100 => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=-3 => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=nan => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=inf => -2
    close.comp=false.skip=-2.off=-1.dur=60.pub=2.5 => -2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=0 => 2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=1 => 2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=5 => 2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=100 => 2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=-3 => 2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=nan => 2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=inf => 2
    close.comp=false.skip=-2.off=-1.dur=-5.pub=2.5 => 2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=0 => -2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=1 => -2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=5 => -2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=100 => -2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=-3 => -2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=nan => -2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=inf => -2
    close.comp=false.skip=-2.off=-1.dur=1000000000.pub=2.5 => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=0 => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=1 => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=5 => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=100 => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=-3 => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=nan => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=inf => -2
    close.comp=false.skip=-2.off=-1.dur=2.5.pub=2.5 => -2
    close.comp=false.skip=-2.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=-2.off=-1.dur=nan.pub=1 => 2
    close.comp=false.skip=-2.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=-2.off=-1.dur=nan.pub=100 => 30
    close.comp=false.skip=-2.off=-1.dur=nan.pub=-3 => 2
    close.comp=false.skip=-2.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=-2.off=-1.dur=nan.pub=inf => 30
    close.comp=false.skip=-2.off=-1.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=-2.off=-1.dur=inf.pub=0 => -2
    close.comp=false.skip=-2.off=-1.dur=inf.pub=1 => -2
    close.comp=false.skip=-2.off=-1.dur=inf.pub=5 => -2
    close.comp=false.skip=-2.off=-1.dur=inf.pub=100 => -2
    close.comp=false.skip=-2.off=-1.dur=inf.pub=-3 => -2
    close.comp=false.skip=-2.off=-1.dur=inf.pub=nan => -2
    close.comp=false.skip=-2.off=-1.dur=inf.pub=inf => -2
    close.comp=false.skip=-2.off=-1.dur=inf.pub=2.5 => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=0 => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=1 => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=5 => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=100 => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=-3 => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=nan => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=inf => -2
    close.comp=false.skip=-2.off=10.dur=nil.pub=2.5 => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=0 => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=1 => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=5 => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=100 => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=-3 => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=nan => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=inf => -2
    close.comp=false.skip=-2.off=10.dur=0.pub=2.5 => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=0 => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=1 => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=5 => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=100 => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=-3 => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=nan => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=inf => -2
    close.comp=false.skip=-2.off=10.dur=10.pub=2.5 => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=0 => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=1 => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=5 => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=100 => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=-3 => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=nan => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=inf => -2
    close.comp=false.skip=-2.off=10.dur=60.pub=2.5 => -2
    close.comp=false.skip=-2.off=10.dur=-5.pub=0 => 2
    close.comp=false.skip=-2.off=10.dur=-5.pub=1 => 2
    close.comp=false.skip=-2.off=10.dur=-5.pub=5 => 2
    close.comp=false.skip=-2.off=10.dur=-5.pub=100 => 2
    close.comp=false.skip=-2.off=10.dur=-5.pub=-3 => 2
    close.comp=false.skip=-2.off=10.dur=-5.pub=nan => 2
    close.comp=false.skip=-2.off=10.dur=-5.pub=inf => 2
    close.comp=false.skip=-2.off=10.dur=-5.pub=2.5 => 2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=0 => -2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=1 => -2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=5 => -2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=100 => -2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=-3 => -2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=nan => -2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=inf => -2
    close.comp=false.skip=-2.off=10.dur=1000000000.pub=2.5 => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=0 => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=1 => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=5 => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=100 => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=-3 => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=nan => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=inf => -2
    close.comp=false.skip=-2.off=10.dur=2.5.pub=2.5 => -2
    close.comp=false.skip=-2.off=10.dur=nan.pub=0 => 2
    close.comp=false.skip=-2.off=10.dur=nan.pub=1 => 2
    close.comp=false.skip=-2.off=10.dur=nan.pub=5 => 5
    close.comp=false.skip=-2.off=10.dur=nan.pub=100 => 30
    close.comp=false.skip=-2.off=10.dur=nan.pub=-3 => 2
    close.comp=false.skip=-2.off=10.dur=nan.pub=nan => nan
    close.comp=false.skip=-2.off=10.dur=nan.pub=inf => 30
    close.comp=false.skip=-2.off=10.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=-2.off=10.dur=inf.pub=0 => -2
    close.comp=false.skip=-2.off=10.dur=inf.pub=1 => -2
    close.comp=false.skip=-2.off=10.dur=inf.pub=5 => -2
    close.comp=false.skip=-2.off=10.dur=inf.pub=100 => -2
    close.comp=false.skip=-2.off=10.dur=inf.pub=-3 => -2
    close.comp=false.skip=-2.off=10.dur=inf.pub=nan => -2
    close.comp=false.skip=-2.off=10.dur=inf.pub=inf => -2
    close.comp=false.skip=-2.off=10.dur=inf.pub=2.5 => -2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=100 => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=inf => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=100 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=inf => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=2.5 => 2
    close.comp=false.skip=nan.off=nil.dur=10.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=10.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=10.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=10.pub=100 => 10
    close.comp=false.skip=nan.off=nil.dur=10.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=10.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=10.pub=inf => 10
    close.comp=false.skip=nan.off=nil.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=nil.dur=60.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=60.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=60.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=60.pub=100 => 30
    close.comp=false.skip=nan.off=nil.dur=60.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=60.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=60.pub=inf => 30
    close.comp=false.skip=nan.off=nil.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=nil.dur=-5.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=-5.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=-5.pub=5 => 2
    close.comp=false.skip=nan.off=nil.dur=-5.pub=100 => 2
    close.comp=false.skip=nan.off=nil.dur=-5.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=-5.pub=nan => 2
    close.comp=false.skip=nan.off=nil.dur=-5.pub=inf => 2
    close.comp=false.skip=nan.off=nil.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=100 => 30
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=inf => 30
    close.comp=false.skip=nan.off=nil.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nan.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=nan.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=nan.pub=100 => 30
    close.comp=false.skip=nan.off=nil.dur=nan.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=nan.pub=inf => 30
    close.comp=false.skip=nan.off=nil.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=nil.dur=inf.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=inf.pub=1 => 2
    close.comp=false.skip=nan.off=nil.dur=inf.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=inf.pub=100 => 30
    close.comp=false.skip=nan.off=nil.dur=inf.pub=-3 => 2
    close.comp=false.skip=nan.off=nil.dur=inf.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=inf.pub=inf => 30
    close.comp=false.skip=nan.off=nil.dur=inf.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=0.dur=nil.pub=0 => 0
    close.comp=false.skip=nan.off=0.dur=nil.pub=1 => 0
    close.comp=false.skip=nan.off=0.dur=nil.pub=5 => 0
    close.comp=false.skip=nan.off=0.dur=nil.pub=100 => 0
    close.comp=false.skip=nan.off=0.dur=nil.pub=-3 => 0
    close.comp=false.skip=nan.off=0.dur=nil.pub=nan => 0
    close.comp=false.skip=nan.off=0.dur=nil.pub=inf => 0
    close.comp=false.skip=nan.off=0.dur=nil.pub=2.5 => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=0 => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=1 => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=5 => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=100 => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=-3 => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=nan => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=inf => 0
    close.comp=false.skip=nan.off=0.dur=0.pub=2.5 => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=0 => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=1 => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=5 => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=100 => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=-3 => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=nan => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=inf => 0
    close.comp=false.skip=nan.off=0.dur=10.pub=2.5 => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=0 => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=1 => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=5 => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=100 => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=-3 => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=nan => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=inf => 0
    close.comp=false.skip=nan.off=0.dur=60.pub=2.5 => 0
    close.comp=false.skip=nan.off=0.dur=-5.pub=0 => 2
    close.comp=false.skip=nan.off=0.dur=-5.pub=1 => 2
    close.comp=false.skip=nan.off=0.dur=-5.pub=5 => 2
    close.comp=false.skip=nan.off=0.dur=-5.pub=100 => 2
    close.comp=false.skip=nan.off=0.dur=-5.pub=-3 => 2
    close.comp=false.skip=nan.off=0.dur=-5.pub=nan => 2
    close.comp=false.skip=nan.off=0.dur=-5.pub=inf => 2
    close.comp=false.skip=nan.off=0.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=0 => 0
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=1 => 0
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=5 => 0
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=100 => 0
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=-3 => 0
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=nan => 0
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=inf => 0
    close.comp=false.skip=nan.off=0.dur=1000000000.pub=2.5 => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=0 => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=1 => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=5 => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=100 => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=-3 => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=nan => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=inf => 0
    close.comp=false.skip=nan.off=0.dur=2.5.pub=2.5 => 0
    close.comp=false.skip=nan.off=0.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=0.dur=nan.pub=1 => 2
    close.comp=false.skip=nan.off=0.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=0.dur=nan.pub=100 => 30
    close.comp=false.skip=nan.off=0.dur=nan.pub=-3 => 2
    close.comp=false.skip=nan.off=0.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=0.dur=nan.pub=inf => 30
    close.comp=false.skip=nan.off=0.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=0.dur=inf.pub=0 => 0
    close.comp=false.skip=nan.off=0.dur=inf.pub=1 => 0
    close.comp=false.skip=nan.off=0.dur=inf.pub=5 => 0
    close.comp=false.skip=nan.off=0.dur=inf.pub=100 => 0
    close.comp=false.skip=nan.off=0.dur=inf.pub=-3 => 0
    close.comp=false.skip=nan.off=0.dur=inf.pub=nan => 0
    close.comp=false.skip=nan.off=0.dur=inf.pub=inf => 0
    close.comp=false.skip=nan.off=0.dur=inf.pub=2.5 => 0
    close.comp=false.skip=nan.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=1 => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=100 => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=-3 => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=inf => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=1 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=100 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=-3 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=inf => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=2.5 => 2
    close.comp=false.skip=nan.off=4.dur=10.pub=0 => 4
    close.comp=false.skip=nan.off=4.dur=10.pub=1 => 4
    close.comp=false.skip=nan.off=4.dur=10.pub=5 => 4
    close.comp=false.skip=nan.off=4.dur=10.pub=100 => 4
    close.comp=false.skip=nan.off=4.dur=10.pub=-3 => 4
    close.comp=false.skip=nan.off=4.dur=10.pub=nan => 4
    close.comp=false.skip=nan.off=4.dur=10.pub=inf => 4
    close.comp=false.skip=nan.off=4.dur=10.pub=2.5 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=0 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=1 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=5 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=100 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=-3 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=nan => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=inf => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=2.5 => 4
    close.comp=false.skip=nan.off=4.dur=-5.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=-5.pub=1 => 2
    close.comp=false.skip=nan.off=4.dur=-5.pub=5 => 2
    close.comp=false.skip=nan.off=4.dur=-5.pub=100 => 2
    close.comp=false.skip=nan.off=4.dur=-5.pub=-3 => 2
    close.comp=false.skip=nan.off=4.dur=-5.pub=nan => 2
    close.comp=false.skip=nan.off=4.dur=-5.pub=inf => 2
    close.comp=false.skip=nan.off=4.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=0 => 4
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=1 => 4
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=5 => 4
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=100 => 4
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=-3 => 4
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=nan => 4
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=inf => 4
    close.comp=false.skip=nan.off=4.dur=1000000000.pub=2.5 => 4
    close.comp=false.skip=nan.off=4.dur=2.5.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=2.5.pub=1 => 2
    close.comp=false.skip=nan.off=4.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nan.off=4.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nan.off=4.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nan.off=4.dur=2.5.pub=nan => nan
    close.comp=false.skip=nan.off=4.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nan.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=nan.pub=1 => 2
    close.comp=false.skip=nan.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=4.dur=nan.pub=100 => 30
    close.comp=false.skip=nan.off=4.dur=nan.pub=-3 => 2
    close.comp=false.skip=nan.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=4.dur=nan.pub=inf => 30
    close.comp=false.skip=nan.off=4.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=4.dur=inf.pub=0 => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=1 => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=5 => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=100 => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=-3 => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=nan => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=inf => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=2.5 => 4
    close.comp=false.skip=nan.off=20.dur=nil.pub=0 => 2
    close.comp=false.skip=nan.off=20.dur=nil.pub=1 => 2
    close.comp=false.skip=nan.off=20.dur=nil.pub=5 => 2
    close.comp=false.skip=nan.off=20.dur=nil.pub=100 => 2
    close.comp=false.skip=nan.off=20.dur=nil.pub=-3 => 2
    close.comp=false.skip=nan.off=20.dur=nil.pub=nan => 2
    close.comp=false.skip=nan.off=20.dur=nil.pub=inf => 2
    close.comp=false.skip=nan.off=20.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=0 => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=1 => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=5 => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=100 => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=-3 => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=nan => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=inf => 2
    close.comp=false.skip=nan.off=20.dur=0.pub=2.5 => 2
    close.comp=false.skip=nan.off=20.dur=10.pub=0 => 2
    close.comp=false.skip=nan.off=20.dur=10.pub=1 => 2
    close.comp=false.skip=nan.off=20.dur=10.pub=5 => 5
    close.comp=false.skip=nan.off=20.dur=10.pub=100 => 10
    close.comp=false.skip=nan.off=20.dur=10.pub=-3 => 2
    close.comp=false.skip=nan.off=20.dur=10.pub=nan => nan
    close.comp=false.skip=nan.off=20.dur=10.pub=inf => 10
    close.comp=false.skip=nan.off=20.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=20.dur=60.pub=0 => 20
    close.comp=false.skip=nan.off=20.dur=60.pub=1 => 20
    close.comp=false.skip=nan.off=20.dur=60.pub=5 => 20
    close.comp=false.skip=nan.off=20.dur=60.pub=100 => 20
    close.comp=false.skip=nan.off=20.dur=60.pub=-3 => 20
    close.comp=false.skip=nan.off=20.dur=60.pub=nan => 20
    close.comp=false.skip=nan.off=20.dur=60.pub=inf => 20
    close.comp=false.skip=nan.off=20.dur=60.pub=2.5 => 20
    close.comp=false.skip=nan.off=20.dur=-5.pub=0 => 2
    close.comp=false.skip=nan.off=20.dur=-5.pub=1 => 2
    close.comp=false.skip=nan.off=20.dur=-5.pub=5 => 2
    close.comp=false.skip=nan.off=20.dur=-5.pub=100 => 2
    close.comp=false.skip=nan.off=20.dur=-5.pub=-3 => 2
    close.comp=false.skip=nan.off=20.dur=-5.pub=nan => 2
    close.comp=false.skip=nan.off=20.dur=-5.pub=inf => 2
    close.comp=false.skip=nan.off=20.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=0 => 20
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=1 => 20
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=5 => 20
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=100 => 20
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=-3 => 20
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=nan => 20
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=inf => 20
    close.comp=false.skip=nan.off=20.dur=1000000000.pub=2.5 => 20
    close.comp=false.skip=nan.off=20.dur=2.5.pub=0 => 2
    close.comp=false.skip=nan.off=20.dur=2.5.pub=1 => 2
    close.comp=false.skip=nan.off=20.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nan.off=20.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nan.off=20.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nan.off=20.dur=2.5.pub=nan => nan
    close.comp=false.skip=nan.off=20.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nan.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=20.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=20.dur=nan.pub=1 => 2
    close.comp=false.skip=nan.off=20.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=20.dur=nan.pub=100 => 30
    close.comp=false.skip=nan.off=20.dur=nan.pub=-3 => 2
    close.comp=false.skip=nan.off=20.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=20.dur=nan.pub=inf => 30
    close.comp=false.skip=nan.off=20.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=20.dur=inf.pub=0 => 20
    close.comp=false.skip=nan.off=20.dur=inf.pub=1 => 20
    close.comp=false.skip=nan.off=20.dur=inf.pub=5 => 20
    close.comp=false.skip=nan.off=20.dur=inf.pub=100 => 20
    close.comp=false.skip=nan.off=20.dur=inf.pub=-3 => 20
    close.comp=false.skip=nan.off=20.dur=inf.pub=nan => 20
    close.comp=false.skip=nan.off=20.dur=inf.pub=inf => 20
    close.comp=false.skip=nan.off=20.dur=inf.pub=2.5 => 20
    close.comp=false.skip=nan.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=1 => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=100 => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=-3 => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=inf => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=2.5 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=1 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=100 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=-3 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=inf => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=2.5 => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=1 => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=100 => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=-3 => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=inf => -1
    close.comp=false.skip=nan.off=-1.dur=10.pub=2.5 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=1 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=100 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=-3 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=inf => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=2.5 => -1
    close.comp=false.skip=nan.off=-1.dur=-5.pub=0 => 2
    close.comp=false.skip=nan.off=-1.dur=-5.pub=1 => 2
    close.comp=false.skip=nan.off=-1.dur=-5.pub=5 => 2
    close.comp=false.skip=nan.off=-1.dur=-5.pub=100 => 2
    close.comp=false.skip=nan.off=-1.dur=-5.pub=-3 => 2
    close.comp=false.skip=nan.off=-1.dur=-5.pub=nan => 2
    close.comp=false.skip=nan.off=-1.dur=-5.pub=inf => 2
    close.comp=false.skip=nan.off=-1.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=1 => -1
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=100 => -1
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=-3 => -1
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=inf => -1
    close.comp=false.skip=nan.off=-1.dur=1000000000.pub=2.5 => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=1 => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=100 => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=-3 => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=inf => -1
    close.comp=false.skip=nan.off=-1.dur=2.5.pub=2.5 => -1
    close.comp=false.skip=nan.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=-1.dur=nan.pub=1 => 2
    close.comp=false.skip=nan.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=-1.dur=nan.pub=100 => 30
    close.comp=false.skip=nan.off=-1.dur=nan.pub=-3 => 2
    close.comp=false.skip=nan.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=-1.dur=nan.pub=inf => 30
    close.comp=false.skip=nan.off=-1.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=-1.dur=inf.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=1 => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=100 => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=-3 => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=inf => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=2.5 => -1
    close.comp=false.skip=nan.off=10.dur=nil.pub=0 => 2
    close.comp=false.skip=nan.off=10.dur=nil.pub=1 => 2
    close.comp=false.skip=nan.off=10.dur=nil.pub=5 => 2
    close.comp=false.skip=nan.off=10.dur=nil.pub=100 => 2
    close.comp=false.skip=nan.off=10.dur=nil.pub=-3 => 2
    close.comp=false.skip=nan.off=10.dur=nil.pub=nan => 2
    close.comp=false.skip=nan.off=10.dur=nil.pub=inf => 2
    close.comp=false.skip=nan.off=10.dur=nil.pub=2.5 => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=0 => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=1 => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=5 => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=100 => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=-3 => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=nan => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=inf => 2
    close.comp=false.skip=nan.off=10.dur=0.pub=2.5 => 2
    close.comp=false.skip=nan.off=10.dur=10.pub=0 => 10
    close.comp=false.skip=nan.off=10.dur=10.pub=1 => 10
    close.comp=false.skip=nan.off=10.dur=10.pub=5 => 10
    close.comp=false.skip=nan.off=10.dur=10.pub=100 => 10
    close.comp=false.skip=nan.off=10.dur=10.pub=-3 => 10
    close.comp=false.skip=nan.off=10.dur=10.pub=nan => 10
    close.comp=false.skip=nan.off=10.dur=10.pub=inf => 10
    close.comp=false.skip=nan.off=10.dur=10.pub=2.5 => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=0 => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=1 => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=5 => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=100 => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=-3 => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=nan => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=inf => 10
    close.comp=false.skip=nan.off=10.dur=60.pub=2.5 => 10
    close.comp=false.skip=nan.off=10.dur=-5.pub=0 => 2
    close.comp=false.skip=nan.off=10.dur=-5.pub=1 => 2
    close.comp=false.skip=nan.off=10.dur=-5.pub=5 => 2
    close.comp=false.skip=nan.off=10.dur=-5.pub=100 => 2
    close.comp=false.skip=nan.off=10.dur=-5.pub=-3 => 2
    close.comp=false.skip=nan.off=10.dur=-5.pub=nan => 2
    close.comp=false.skip=nan.off=10.dur=-5.pub=inf => 2
    close.comp=false.skip=nan.off=10.dur=-5.pub=2.5 => 2
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=0 => 10
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=1 => 10
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=5 => 10
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=100 => 10
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=-3 => 10
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=nan => 10
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=inf => 10
    close.comp=false.skip=nan.off=10.dur=1000000000.pub=2.5 => 10
    close.comp=false.skip=nan.off=10.dur=2.5.pub=0 => 2
    close.comp=false.skip=nan.off=10.dur=2.5.pub=1 => 2
    close.comp=false.skip=nan.off=10.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=nan.off=10.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=nan.off=10.dur=2.5.pub=-3 => 2
    close.comp=false.skip=nan.off=10.dur=2.5.pub=nan => nan
    close.comp=false.skip=nan.off=10.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=nan.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=10.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=10.dur=nan.pub=1 => 2
    close.comp=false.skip=nan.off=10.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=10.dur=nan.pub=100 => 30
    close.comp=false.skip=nan.off=10.dur=nan.pub=-3 => 2
    close.comp=false.skip=nan.off=10.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=10.dur=nan.pub=inf => 30
    close.comp=false.skip=nan.off=10.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=nan.off=10.dur=inf.pub=0 => 10
    close.comp=false.skip=nan.off=10.dur=inf.pub=1 => 10
    close.comp=false.skip=nan.off=10.dur=inf.pub=5 => 10
    close.comp=false.skip=nan.off=10.dur=inf.pub=100 => 10
    close.comp=false.skip=nan.off=10.dur=inf.pub=-3 => 10
    close.comp=false.skip=nan.off=10.dur=inf.pub=nan => 10
    close.comp=false.skip=nan.off=10.dur=inf.pub=inf => 10
    close.comp=false.skip=nan.off=10.dur=inf.pub=2.5 => 10
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=1 => 2
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=100 => 2
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=-3 => 2
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=inf => 2
    close.comp=false.skip=2.5.off=nil.dur=nil.pub=2.5 => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=1 => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=100 => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=-3 => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=inf => 2
    close.comp=false.skip=2.5.off=nil.dur=0.pub=2.5 => 2
    close.comp=false.skip=2.5.off=nil.dur=10.pub=0 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=10.pub=1 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=10.pub=5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=10.pub=100 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=10.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=10.pub=nan => 2.5
    close.comp=false.skip=2.5.off=nil.dur=10.pub=inf => 2.5
    close.comp=false.skip=2.5.off=nil.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=0 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=1 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=100 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=nan => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=inf => 2.5
    close.comp=false.skip=2.5.off=nil.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=0 => 2
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=1 => 2
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=5 => 2
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=100 => 2
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=-3 => 2
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=nan => 2
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=inf => 2
    close.comp=false.skip=2.5.off=nil.dur=-5.pub=2.5 => 2
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=0 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=1 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=100 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=nan => 2.5
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=inf => 2.5
    close.comp=false.skip=2.5.off=nil.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=2.5.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=1 => 2
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=100 => 30
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=-3 => 2
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=inf => 30
    close.comp=false.skip=2.5.off=nil.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=0 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=1 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=5 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=100 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=nan => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=inf => 2.5
    close.comp=false.skip=2.5.off=nil.dur=inf.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=nil.pub=0 => 0
    close.comp=false.skip=2.5.off=0.dur=nil.pub=1 => 0
    close.comp=false.skip=2.5.off=0.dur=nil.pub=5 => 0
    close.comp=false.skip=2.5.off=0.dur=nil.pub=100 => 0
    close.comp=false.skip=2.5.off=0.dur=nil.pub=-3 => 0
    close.comp=false.skip=2.5.off=0.dur=nil.pub=nan => 0
    close.comp=false.skip=2.5.off=0.dur=nil.pub=inf => 0
    close.comp=false.skip=2.5.off=0.dur=nil.pub=2.5 => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=0 => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=1 => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=5 => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=100 => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=-3 => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=nan => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=inf => 0
    close.comp=false.skip=2.5.off=0.dur=0.pub=2.5 => 0
    close.comp=false.skip=2.5.off=0.dur=10.pub=0 => 2.5
    close.comp=false.skip=2.5.off=0.dur=10.pub=1 => 2.5
    close.comp=false.skip=2.5.off=0.dur=10.pub=5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=10.pub=100 => 2.5
    close.comp=false.skip=2.5.off=0.dur=10.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=0.dur=10.pub=nan => 2.5
    close.comp=false.skip=2.5.off=0.dur=10.pub=inf => 2.5
    close.comp=false.skip=2.5.off=0.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=0 => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=1 => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=100 => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=nan => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=inf => 2.5
    close.comp=false.skip=2.5.off=0.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=-5.pub=0 => 2
    close.comp=false.skip=2.5.off=0.dur=-5.pub=1 => 2
    close.comp=false.skip=2.5.off=0.dur=-5.pub=5 => 2
    close.comp=false.skip=2.5.off=0.dur=-5.pub=100 => 2
    close.comp=false.skip=2.5.off=0.dur=-5.pub=-3 => 2
    close.comp=false.skip=2.5.off=0.dur=-5.pub=nan => 2
    close.comp=false.skip=2.5.off=0.dur=-5.pub=inf => 2
    close.comp=false.skip=2.5.off=0.dur=-5.pub=2.5 => 2
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=0 => 2.5
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=1 => 2.5
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=100 => 2.5
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=nan => 2.5
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=inf => 2.5
    close.comp=false.skip=2.5.off=0.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=0 => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=1 => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=nan => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=2.5.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=nan.pub=0 => 2
    close.comp=false.skip=2.5.off=0.dur=nan.pub=1 => 2
    close.comp=false.skip=2.5.off=0.dur=nan.pub=5 => 5
    close.comp=false.skip=2.5.off=0.dur=nan.pub=100 => 30
    close.comp=false.skip=2.5.off=0.dur=nan.pub=-3 => 2
    close.comp=false.skip=2.5.off=0.dur=nan.pub=nan => nan
    close.comp=false.skip=2.5.off=0.dur=nan.pub=inf => 30
    close.comp=false.skip=2.5.off=0.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=0 => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=1 => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=5 => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=100 => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=nan => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=inf => 2.5
    close.comp=false.skip=2.5.off=0.dur=inf.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=2.5.off=4.dur=nil.pub=1 => 2
    close.comp=false.skip=2.5.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=2.5.off=4.dur=nil.pub=100 => 2
    close.comp=false.skip=2.5.off=4.dur=nil.pub=-3 => 2
    close.comp=false.skip=2.5.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=2.5.off=4.dur=nil.pub=inf => 2
    close.comp=false.skip=2.5.off=4.dur=nil.pub=2.5 => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=1 => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=100 => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=-3 => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=inf => 2
    close.comp=false.skip=2.5.off=4.dur=0.pub=2.5 => 2
    close.comp=false.skip=2.5.off=4.dur=10.pub=0 => 2.5
    close.comp=false.skip=2.5.off=4.dur=10.pub=1 => 2.5
    close.comp=false.skip=2.5.off=4.dur=10.pub=5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=10.pub=100 => 2.5
    close.comp=false.skip=2.5.off=4.dur=10.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=4.dur=10.pub=nan => 2.5
    close.comp=false.skip=2.5.off=4.dur=10.pub=inf => 2.5
    close.comp=false.skip=2.5.off=4.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=0 => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=1 => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=100 => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=nan => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=inf => 2.5
    close.comp=false.skip=2.5.off=4.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=-5.pub=0 => 2
    close.comp=false.skip=2.5.off=4.dur=-5.pub=1 => 2
    close.comp=false.skip=2.5.off=4.dur=-5.pub=5 => 2
    close.comp=false.skip=2.5.off=4.dur=-5.pub=100 => 2
    close.comp=false.skip=2.5.off=4.dur=-5.pub=-3 => 2
    close.comp=false.skip=2.5.off=4.dur=-5.pub=nan => 2
    close.comp=false.skip=2.5.off=4.dur=-5.pub=inf => 2
    close.comp=false.skip=2.5.off=4.dur=-5.pub=2.5 => 2
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=0 => 2.5
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=1 => 2.5
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=100 => 2.5
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=nan => 2.5
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=inf => 2.5
    close.comp=false.skip=2.5.off=4.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=0 => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=1 => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=nan => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=2.5.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=2.5.off=4.dur=nan.pub=1 => 2
    close.comp=false.skip=2.5.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=2.5.off=4.dur=nan.pub=100 => 30
    close.comp=false.skip=2.5.off=4.dur=nan.pub=-3 => 2
    close.comp=false.skip=2.5.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=2.5.off=4.dur=nan.pub=inf => 30
    close.comp=false.skip=2.5.off=4.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=0 => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=1 => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=5 => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=100 => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=nan => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=inf => 2.5
    close.comp=false.skip=2.5.off=4.dur=inf.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=nil.pub=0 => 2
    close.comp=false.skip=2.5.off=20.dur=nil.pub=1 => 2
    close.comp=false.skip=2.5.off=20.dur=nil.pub=5 => 2
    close.comp=false.skip=2.5.off=20.dur=nil.pub=100 => 2
    close.comp=false.skip=2.5.off=20.dur=nil.pub=-3 => 2
    close.comp=false.skip=2.5.off=20.dur=nil.pub=nan => 2
    close.comp=false.skip=2.5.off=20.dur=nil.pub=inf => 2
    close.comp=false.skip=2.5.off=20.dur=nil.pub=2.5 => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=0 => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=1 => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=5 => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=100 => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=-3 => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=nan => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=inf => 2
    close.comp=false.skip=2.5.off=20.dur=0.pub=2.5 => 2
    close.comp=false.skip=2.5.off=20.dur=10.pub=0 => 2.5
    close.comp=false.skip=2.5.off=20.dur=10.pub=1 => 2.5
    close.comp=false.skip=2.5.off=20.dur=10.pub=5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=10.pub=100 => 2.5
    close.comp=false.skip=2.5.off=20.dur=10.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=20.dur=10.pub=nan => 2.5
    close.comp=false.skip=2.5.off=20.dur=10.pub=inf => 2.5
    close.comp=false.skip=2.5.off=20.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=0 => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=1 => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=100 => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=nan => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=inf => 2.5
    close.comp=false.skip=2.5.off=20.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=-5.pub=0 => 2
    close.comp=false.skip=2.5.off=20.dur=-5.pub=1 => 2
    close.comp=false.skip=2.5.off=20.dur=-5.pub=5 => 2
    close.comp=false.skip=2.5.off=20.dur=-5.pub=100 => 2
    close.comp=false.skip=2.5.off=20.dur=-5.pub=-3 => 2
    close.comp=false.skip=2.5.off=20.dur=-5.pub=nan => 2
    close.comp=false.skip=2.5.off=20.dur=-5.pub=inf => 2
    close.comp=false.skip=2.5.off=20.dur=-5.pub=2.5 => 2
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=0 => 2.5
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=1 => 2.5
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=100 => 2.5
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=nan => 2.5
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=inf => 2.5
    close.comp=false.skip=2.5.off=20.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=0 => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=1 => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=nan => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=2.5.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=nan.pub=0 => 2
    close.comp=false.skip=2.5.off=20.dur=nan.pub=1 => 2
    close.comp=false.skip=2.5.off=20.dur=nan.pub=5 => 5
    close.comp=false.skip=2.5.off=20.dur=nan.pub=100 => 30
    close.comp=false.skip=2.5.off=20.dur=nan.pub=-3 => 2
    close.comp=false.skip=2.5.off=20.dur=nan.pub=nan => nan
    close.comp=false.skip=2.5.off=20.dur=nan.pub=inf => 30
    close.comp=false.skip=2.5.off=20.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=0 => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=1 => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=5 => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=100 => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=nan => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=inf => 2.5
    close.comp=false.skip=2.5.off=20.dur=inf.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=1 => -1
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=100 => -1
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=-3 => -1
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=inf => -1
    close.comp=false.skip=2.5.off=-1.dur=nil.pub=2.5 => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=1 => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=100 => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=-3 => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=inf => -1
    close.comp=false.skip=2.5.off=-1.dur=0.pub=2.5 => -1
    close.comp=false.skip=2.5.off=-1.dur=10.pub=0 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=10.pub=1 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=10.pub=5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=10.pub=100 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=10.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=10.pub=nan => 2.5
    close.comp=false.skip=2.5.off=-1.dur=10.pub=inf => 2.5
    close.comp=false.skip=2.5.off=-1.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=0 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=1 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=100 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=nan => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=inf => 2.5
    close.comp=false.skip=2.5.off=-1.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=0 => 2
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=1 => 2
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=5 => 2
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=100 => 2
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=-3 => 2
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=nan => 2
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=inf => 2
    close.comp=false.skip=2.5.off=-1.dur=-5.pub=2.5 => 2
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=0 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=1 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=100 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=nan => 2.5
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=inf => 2.5
    close.comp=false.skip=2.5.off=-1.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=2.5.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=1 => 2
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=100 => 30
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=-3 => 2
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=inf => 30
    close.comp=false.skip=2.5.off=-1.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=0 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=1 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=5 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=100 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=nan => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=inf => 2.5
    close.comp=false.skip=2.5.off=-1.dur=inf.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=nil.pub=0 => 2
    close.comp=false.skip=2.5.off=10.dur=nil.pub=1 => 2
    close.comp=false.skip=2.5.off=10.dur=nil.pub=5 => 2
    close.comp=false.skip=2.5.off=10.dur=nil.pub=100 => 2
    close.comp=false.skip=2.5.off=10.dur=nil.pub=-3 => 2
    close.comp=false.skip=2.5.off=10.dur=nil.pub=nan => 2
    close.comp=false.skip=2.5.off=10.dur=nil.pub=inf => 2
    close.comp=false.skip=2.5.off=10.dur=nil.pub=2.5 => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=0 => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=1 => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=5 => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=100 => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=-3 => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=nan => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=inf => 2
    close.comp=false.skip=2.5.off=10.dur=0.pub=2.5 => 2
    close.comp=false.skip=2.5.off=10.dur=10.pub=0 => 2.5
    close.comp=false.skip=2.5.off=10.dur=10.pub=1 => 2.5
    close.comp=false.skip=2.5.off=10.dur=10.pub=5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=10.pub=100 => 2.5
    close.comp=false.skip=2.5.off=10.dur=10.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=10.dur=10.pub=nan => 2.5
    close.comp=false.skip=2.5.off=10.dur=10.pub=inf => 2.5
    close.comp=false.skip=2.5.off=10.dur=10.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=0 => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=1 => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=100 => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=nan => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=inf => 2.5
    close.comp=false.skip=2.5.off=10.dur=60.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=-5.pub=0 => 2
    close.comp=false.skip=2.5.off=10.dur=-5.pub=1 => 2
    close.comp=false.skip=2.5.off=10.dur=-5.pub=5 => 2
    close.comp=false.skip=2.5.off=10.dur=-5.pub=100 => 2
    close.comp=false.skip=2.5.off=10.dur=-5.pub=-3 => 2
    close.comp=false.skip=2.5.off=10.dur=-5.pub=nan => 2
    close.comp=false.skip=2.5.off=10.dur=-5.pub=inf => 2
    close.comp=false.skip=2.5.off=10.dur=-5.pub=2.5 => 2
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=0 => 2.5
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=1 => 2.5
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=100 => 2.5
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=nan => 2.5
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=inf => 2.5
    close.comp=false.skip=2.5.off=10.dur=1000000000.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=0 => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=1 => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=100 => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=nan => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=inf => 2.5
    close.comp=false.skip=2.5.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=nan.pub=0 => 2
    close.comp=false.skip=2.5.off=10.dur=nan.pub=1 => 2
    close.comp=false.skip=2.5.off=10.dur=nan.pub=5 => 5
    close.comp=false.skip=2.5.off=10.dur=nan.pub=100 => 30
    close.comp=false.skip=2.5.off=10.dur=nan.pub=-3 => 2
    close.comp=false.skip=2.5.off=10.dur=nan.pub=nan => nan
    close.comp=false.skip=2.5.off=10.dur=nan.pub=inf => 30
    close.comp=false.skip=2.5.off=10.dur=nan.pub=2.5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=0 => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=1 => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=5 => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=100 => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=-3 => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=nan => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=inf => 2.5
    close.comp=false.skip=2.5.off=10.dur=inf.pub=2.5 => 2.5
    close.comp=true.skip=nil.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=1 => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=100 => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=-3 => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=inf => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=1 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=100 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=-3 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=inf => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=2.5 => 0
    close.comp=true.skip=nil.off=nil.dur=10.pub=0 => 10
    close.comp=true.skip=nil.off=nil.dur=10.pub=1 => 10
    close.comp=true.skip=nil.off=nil.dur=10.pub=5 => 10
    close.comp=true.skip=nil.off=nil.dur=10.pub=100 => 10
    close.comp=true.skip=nil.off=nil.dur=10.pub=-3 => 10
    close.comp=true.skip=nil.off=nil.dur=10.pub=nan => 10
    close.comp=true.skip=nil.off=nil.dur=10.pub=inf => 10
    close.comp=true.skip=nil.off=nil.dur=10.pub=2.5 => 10
    close.comp=true.skip=nil.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=1 => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=100 => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=-3 => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=inf => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=2.5 => 60
    close.comp=true.skip=nil.off=nil.dur=-5.pub=0 => -5
    close.comp=true.skip=nil.off=nil.dur=-5.pub=1 => -5
    close.comp=true.skip=nil.off=nil.dur=-5.pub=5 => -5
    close.comp=true.skip=nil.off=nil.dur=-5.pub=100 => -5
    close.comp=true.skip=nil.off=nil.dur=-5.pub=-3 => -5
    close.comp=true.skip=nil.off=nil.dur=-5.pub=nan => -5
    close.comp=true.skip=nil.off=nil.dur=-5.pub=inf => -5
    close.comp=true.skip=nil.off=nil.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nil.off=nil.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nil.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nil.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=1 => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=100 => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=-3 => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=inf => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nil.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=1 => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=100 => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=-3 => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=inf => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nil.off=0.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=0.dur=nil.pub=1 => 0
    close.comp=true.skip=nil.off=0.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=0.dur=nil.pub=100 => 0
    close.comp=true.skip=nil.off=0.dur=nil.pub=-3 => 0
    close.comp=true.skip=nil.off=0.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=0.dur=nil.pub=inf => 0
    close.comp=true.skip=nil.off=0.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=1 => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=100 => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=-3 => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=inf => 0
    close.comp=true.skip=nil.off=0.dur=0.pub=2.5 => 0
    close.comp=true.skip=nil.off=0.dur=10.pub=0 => 10
    close.comp=true.skip=nil.off=0.dur=10.pub=1 => 10
    close.comp=true.skip=nil.off=0.dur=10.pub=5 => 10
    close.comp=true.skip=nil.off=0.dur=10.pub=100 => 10
    close.comp=true.skip=nil.off=0.dur=10.pub=-3 => 10
    close.comp=true.skip=nil.off=0.dur=10.pub=nan => 10
    close.comp=true.skip=nil.off=0.dur=10.pub=inf => 10
    close.comp=true.skip=nil.off=0.dur=10.pub=2.5 => 10
    close.comp=true.skip=nil.off=0.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=0.dur=60.pub=1 => 60
    close.comp=true.skip=nil.off=0.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=0.dur=60.pub=100 => 60
    close.comp=true.skip=nil.off=0.dur=60.pub=-3 => 60
    close.comp=true.skip=nil.off=0.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=0.dur=60.pub=inf => 60
    close.comp=true.skip=nil.off=0.dur=60.pub=2.5 => 60
    close.comp=true.skip=nil.off=0.dur=-5.pub=0 => -5
    close.comp=true.skip=nil.off=0.dur=-5.pub=1 => -5
    close.comp=true.skip=nil.off=0.dur=-5.pub=5 => -5
    close.comp=true.skip=nil.off=0.dur=-5.pub=100 => -5
    close.comp=true.skip=nil.off=0.dur=-5.pub=-3 => -5
    close.comp=true.skip=nil.off=0.dur=-5.pub=nan => -5
    close.comp=true.skip=nil.off=0.dur=-5.pub=inf => -5
    close.comp=true.skip=nil.off=0.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nil.off=0.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nil.off=0.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nil.off=0.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nil.off=0.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nil.off=0.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nil.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nil.off=0.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nil.off=0.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nil.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nil.off=0.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=0.dur=nan.pub=1 => nan
    close.comp=true.skip=nil.off=0.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=0.dur=nan.pub=100 => nan
    close.comp=true.skip=nil.off=0.dur=nan.pub=-3 => nan
    close.comp=true.skip=nil.off=0.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=0.dur=nan.pub=inf => nan
    close.comp=true.skip=nil.off=0.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nil.off=0.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=0.dur=inf.pub=1 => inf
    close.comp=true.skip=nil.off=0.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=0.dur=inf.pub=100 => inf
    close.comp=true.skip=nil.off=0.dur=inf.pub=-3 => inf
    close.comp=true.skip=nil.off=0.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=0.dur=inf.pub=inf => inf
    close.comp=true.skip=nil.off=0.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nil.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=1 => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=100 => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=-3 => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=inf => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=1 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=100 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=-3 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=inf => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=2.5 => 0
    close.comp=true.skip=nil.off=4.dur=10.pub=0 => 10
    close.comp=true.skip=nil.off=4.dur=10.pub=1 => 10
    close.comp=true.skip=nil.off=4.dur=10.pub=5 => 10
    close.comp=true.skip=nil.off=4.dur=10.pub=100 => 10
    close.comp=true.skip=nil.off=4.dur=10.pub=-3 => 10
    close.comp=true.skip=nil.off=4.dur=10.pub=nan => 10
    close.comp=true.skip=nil.off=4.dur=10.pub=inf => 10
    close.comp=true.skip=nil.off=4.dur=10.pub=2.5 => 10
    close.comp=true.skip=nil.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=1 => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=100 => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=-3 => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=inf => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=2.5 => 60
    close.comp=true.skip=nil.off=4.dur=-5.pub=0 => -5
    close.comp=true.skip=nil.off=4.dur=-5.pub=1 => -5
    close.comp=true.skip=nil.off=4.dur=-5.pub=5 => -5
    close.comp=true.skip=nil.off=4.dur=-5.pub=100 => -5
    close.comp=true.skip=nil.off=4.dur=-5.pub=-3 => -5
    close.comp=true.skip=nil.off=4.dur=-5.pub=nan => -5
    close.comp=true.skip=nil.off=4.dur=-5.pub=inf => -5
    close.comp=true.skip=nil.off=4.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nil.off=4.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nil.off=4.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nil.off=4.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nil.off=4.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nil.off=4.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nil.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nil.off=4.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nil.off=4.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nil.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nil.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=1 => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=100 => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=-3 => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=inf => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nil.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=1 => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=100 => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=-3 => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=inf => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nil.off=20.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=20.dur=nil.pub=1 => 0
    close.comp=true.skip=nil.off=20.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=20.dur=nil.pub=100 => 0
    close.comp=true.skip=nil.off=20.dur=nil.pub=-3 => 0
    close.comp=true.skip=nil.off=20.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=20.dur=nil.pub=inf => 0
    close.comp=true.skip=nil.off=20.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=1 => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=100 => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=-3 => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=inf => 0
    close.comp=true.skip=nil.off=20.dur=0.pub=2.5 => 0
    close.comp=true.skip=nil.off=20.dur=10.pub=0 => 10
    close.comp=true.skip=nil.off=20.dur=10.pub=1 => 10
    close.comp=true.skip=nil.off=20.dur=10.pub=5 => 10
    close.comp=true.skip=nil.off=20.dur=10.pub=100 => 10
    close.comp=true.skip=nil.off=20.dur=10.pub=-3 => 10
    close.comp=true.skip=nil.off=20.dur=10.pub=nan => 10
    close.comp=true.skip=nil.off=20.dur=10.pub=inf => 10
    close.comp=true.skip=nil.off=20.dur=10.pub=2.5 => 10
    close.comp=true.skip=nil.off=20.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=20.dur=60.pub=1 => 60
    close.comp=true.skip=nil.off=20.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=20.dur=60.pub=100 => 60
    close.comp=true.skip=nil.off=20.dur=60.pub=-3 => 60
    close.comp=true.skip=nil.off=20.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=20.dur=60.pub=inf => 60
    close.comp=true.skip=nil.off=20.dur=60.pub=2.5 => 60
    close.comp=true.skip=nil.off=20.dur=-5.pub=0 => -5
    close.comp=true.skip=nil.off=20.dur=-5.pub=1 => -5
    close.comp=true.skip=nil.off=20.dur=-5.pub=5 => -5
    close.comp=true.skip=nil.off=20.dur=-5.pub=100 => -5
    close.comp=true.skip=nil.off=20.dur=-5.pub=-3 => -5
    close.comp=true.skip=nil.off=20.dur=-5.pub=nan => -5
    close.comp=true.skip=nil.off=20.dur=-5.pub=inf => -5
    close.comp=true.skip=nil.off=20.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nil.off=20.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nil.off=20.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nil.off=20.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nil.off=20.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nil.off=20.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nil.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nil.off=20.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nil.off=20.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nil.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nil.off=20.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=20.dur=nan.pub=1 => nan
    close.comp=true.skip=nil.off=20.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=20.dur=nan.pub=100 => nan
    close.comp=true.skip=nil.off=20.dur=nan.pub=-3 => nan
    close.comp=true.skip=nil.off=20.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=20.dur=nan.pub=inf => nan
    close.comp=true.skip=nil.off=20.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nil.off=20.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=20.dur=inf.pub=1 => inf
    close.comp=true.skip=nil.off=20.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=20.dur=inf.pub=100 => inf
    close.comp=true.skip=nil.off=20.dur=inf.pub=-3 => inf
    close.comp=true.skip=nil.off=20.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=20.dur=inf.pub=inf => inf
    close.comp=true.skip=nil.off=20.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nil.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=1 => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=100 => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=-3 => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=inf => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=1 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=100 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=-3 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=inf => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=2.5 => 0
    close.comp=true.skip=nil.off=-1.dur=10.pub=0 => 10
    close.comp=true.skip=nil.off=-1.dur=10.pub=1 => 10
    close.comp=true.skip=nil.off=-1.dur=10.pub=5 => 10
    close.comp=true.skip=nil.off=-1.dur=10.pub=100 => 10
    close.comp=true.skip=nil.off=-1.dur=10.pub=-3 => 10
    close.comp=true.skip=nil.off=-1.dur=10.pub=nan => 10
    close.comp=true.skip=nil.off=-1.dur=10.pub=inf => 10
    close.comp=true.skip=nil.off=-1.dur=10.pub=2.5 => 10
    close.comp=true.skip=nil.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=1 => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=100 => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=-3 => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=inf => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=2.5 => 60
    close.comp=true.skip=nil.off=-1.dur=-5.pub=0 => -5
    close.comp=true.skip=nil.off=-1.dur=-5.pub=1 => -5
    close.comp=true.skip=nil.off=-1.dur=-5.pub=5 => -5
    close.comp=true.skip=nil.off=-1.dur=-5.pub=100 => -5
    close.comp=true.skip=nil.off=-1.dur=-5.pub=-3 => -5
    close.comp=true.skip=nil.off=-1.dur=-5.pub=nan => -5
    close.comp=true.skip=nil.off=-1.dur=-5.pub=inf => -5
    close.comp=true.skip=nil.off=-1.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nil.off=-1.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nil.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nil.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=1 => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=100 => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=-3 => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=inf => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nil.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=1 => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=100 => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=-3 => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=inf => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nil.off=10.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=10.dur=nil.pub=1 => 0
    close.comp=true.skip=nil.off=10.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=10.dur=nil.pub=100 => 0
    close.comp=true.skip=nil.off=10.dur=nil.pub=-3 => 0
    close.comp=true.skip=nil.off=10.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=10.dur=nil.pub=inf => 0
    close.comp=true.skip=nil.off=10.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=1 => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=100 => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=-3 => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=inf => 0
    close.comp=true.skip=nil.off=10.dur=0.pub=2.5 => 0
    close.comp=true.skip=nil.off=10.dur=10.pub=0 => 10
    close.comp=true.skip=nil.off=10.dur=10.pub=1 => 10
    close.comp=true.skip=nil.off=10.dur=10.pub=5 => 10
    close.comp=true.skip=nil.off=10.dur=10.pub=100 => 10
    close.comp=true.skip=nil.off=10.dur=10.pub=-3 => 10
    close.comp=true.skip=nil.off=10.dur=10.pub=nan => 10
    close.comp=true.skip=nil.off=10.dur=10.pub=inf => 10
    close.comp=true.skip=nil.off=10.dur=10.pub=2.5 => 10
    close.comp=true.skip=nil.off=10.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=10.dur=60.pub=1 => 60
    close.comp=true.skip=nil.off=10.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=10.dur=60.pub=100 => 60
    close.comp=true.skip=nil.off=10.dur=60.pub=-3 => 60
    close.comp=true.skip=nil.off=10.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=10.dur=60.pub=inf => 60
    close.comp=true.skip=nil.off=10.dur=60.pub=2.5 => 60
    close.comp=true.skip=nil.off=10.dur=-5.pub=0 => -5
    close.comp=true.skip=nil.off=10.dur=-5.pub=1 => -5
    close.comp=true.skip=nil.off=10.dur=-5.pub=5 => -5
    close.comp=true.skip=nil.off=10.dur=-5.pub=100 => -5
    close.comp=true.skip=nil.off=10.dur=-5.pub=-3 => -5
    close.comp=true.skip=nil.off=10.dur=-5.pub=nan => -5
    close.comp=true.skip=nil.off=10.dur=-5.pub=inf => -5
    close.comp=true.skip=nil.off=10.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nil.off=10.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nil.off=10.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nil.off=10.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nil.off=10.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nil.off=10.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nil.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nil.off=10.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nil.off=10.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nil.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nil.off=10.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=10.dur=nan.pub=1 => nan
    close.comp=true.skip=nil.off=10.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=10.dur=nan.pub=100 => nan
    close.comp=true.skip=nil.off=10.dur=nan.pub=-3 => nan
    close.comp=true.skip=nil.off=10.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=10.dur=nan.pub=inf => nan
    close.comp=true.skip=nil.off=10.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nil.off=10.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=10.dur=inf.pub=1 => inf
    close.comp=true.skip=nil.off=10.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=10.dur=inf.pub=100 => inf
    close.comp=true.skip=nil.off=10.dur=inf.pub=-3 => inf
    close.comp=true.skip=nil.off=10.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=10.dur=inf.pub=inf => inf
    close.comp=true.skip=nil.off=10.dur=inf.pub=2.5 => inf
    close.comp=true.skip=0.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=0.off=nil.dur=nil.pub=1 => 0
    close.comp=true.skip=0.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=0.off=nil.dur=nil.pub=100 => 0
    close.comp=true.skip=0.off=nil.dur=nil.pub=-3 => 0
    close.comp=true.skip=0.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=0.off=nil.dur=nil.pub=inf => 0
    close.comp=true.skip=0.off=nil.dur=nil.pub=2.5 => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=1 => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=100 => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=-3 => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=inf => 0
    close.comp=true.skip=0.off=nil.dur=0.pub=2.5 => 0
    close.comp=true.skip=0.off=nil.dur=10.pub=0 => 10
    close.comp=true.skip=0.off=nil.dur=10.pub=1 => 10
    close.comp=true.skip=0.off=nil.dur=10.pub=5 => 10
    close.comp=true.skip=0.off=nil.dur=10.pub=100 => 10
    close.comp=true.skip=0.off=nil.dur=10.pub=-3 => 10
    close.comp=true.skip=0.off=nil.dur=10.pub=nan => 10
    close.comp=true.skip=0.off=nil.dur=10.pub=inf => 10
    close.comp=true.skip=0.off=nil.dur=10.pub=2.5 => 10
    close.comp=true.skip=0.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=0.off=nil.dur=60.pub=1 => 60
    close.comp=true.skip=0.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=0.off=nil.dur=60.pub=100 => 60
    close.comp=true.skip=0.off=nil.dur=60.pub=-3 => 60
    close.comp=true.skip=0.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=0.off=nil.dur=60.pub=inf => 60
    close.comp=true.skip=0.off=nil.dur=60.pub=2.5 => 60
    close.comp=true.skip=0.off=nil.dur=-5.pub=0 => -5
    close.comp=true.skip=0.off=nil.dur=-5.pub=1 => -5
    close.comp=true.skip=0.off=nil.dur=-5.pub=5 => -5
    close.comp=true.skip=0.off=nil.dur=-5.pub=100 => -5
    close.comp=true.skip=0.off=nil.dur=-5.pub=-3 => -5
    close.comp=true.skip=0.off=nil.dur=-5.pub=nan => -5
    close.comp=true.skip=0.off=nil.dur=-5.pub=inf => -5
    close.comp=true.skip=0.off=nil.dur=-5.pub=2.5 => -5
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=0.off=nil.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=0.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=0.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=0.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=0.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=0.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=0.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=0.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=0.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=0.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=0.off=nil.dur=nan.pub=1 => nan
    close.comp=true.skip=0.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=0.off=nil.dur=nan.pub=100 => nan
    close.comp=true.skip=0.off=nil.dur=nan.pub=-3 => nan
    close.comp=true.skip=0.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=0.off=nil.dur=nan.pub=inf => nan
    close.comp=true.skip=0.off=nil.dur=nan.pub=2.5 => nan
    close.comp=true.skip=0.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=0.off=nil.dur=inf.pub=1 => inf
    close.comp=true.skip=0.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=0.off=nil.dur=inf.pub=100 => inf
    close.comp=true.skip=0.off=nil.dur=inf.pub=-3 => inf
    close.comp=true.skip=0.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=0.off=nil.dur=inf.pub=inf => inf
    close.comp=true.skip=0.off=nil.dur=inf.pub=2.5 => inf
    close.comp=true.skip=0.off=0.dur=nil.pub=0 => 0
    close.comp=true.skip=0.off=0.dur=nil.pub=1 => 0
    close.comp=true.skip=0.off=0.dur=nil.pub=5 => 0
    close.comp=true.skip=0.off=0.dur=nil.pub=100 => 0
    close.comp=true.skip=0.off=0.dur=nil.pub=-3 => 0
    close.comp=true.skip=0.off=0.dur=nil.pub=nan => 0
    close.comp=true.skip=0.off=0.dur=nil.pub=inf => 0
    close.comp=true.skip=0.off=0.dur=nil.pub=2.5 => 0
    close.comp=true.skip=0.off=0.dur=0.pub=0 => 0
    close.comp=true.skip=0.off=0.dur=0.pub=1 => 0
    close.comp=true.skip=0.off=0.dur=0.pub=5 => 0
    close.comp=true.skip=0.off=0.dur=0.pub=100 => 0
    close.comp=true.skip=0.off=0.dur=0.pub=-3 => 0
    close.comp=true.skip=0.off=0.dur=0.pub=nan => 0
    close.comp=true.skip=0.off=0.dur=0.pub=inf => 0
    close.comp=true.skip=0.off=0.dur=0.pub=2.5 => 0
    close.comp=true.skip=0.off=0.dur=10.pub=0 => 10
    close.comp=true.skip=0.off=0.dur=10.pub=1 => 10
    close.comp=true.skip=0.off=0.dur=10.pub=5 => 10
    close.comp=true.skip=0.off=0.dur=10.pub=100 => 10
    close.comp=true.skip=0.off=0.dur=10.pub=-3 => 10
    close.comp=true.skip=0.off=0.dur=10.pub=nan => 10
    close.comp=true.skip=0.off=0.dur=10.pub=inf => 10
    close.comp=true.skip=0.off=0.dur=10.pub=2.5 => 10
    close.comp=true.skip=0.off=0.dur=60.pub=0 => 60
    close.comp=true.skip=0.off=0.dur=60.pub=1 => 60
    close.comp=true.skip=0.off=0.dur=60.pub=5 => 60
    close.comp=true.skip=0.off=0.dur=60.pub=100 => 60
    close.comp=true.skip=0.off=0.dur=60.pub=-3 => 60
    close.comp=true.skip=0.off=0.dur=60.pub=nan => 60
    close.comp=true.skip=0.off=0.dur=60.pub=inf => 60
    close.comp=true.skip=0.off=0.dur=60.pub=2.5 => 60
    close.comp=true.skip=0.off=0.dur=-5.pub=0 => -5
    close.comp=true.skip=0.off=0.dur=-5.pub=1 => -5
    close.comp=true.skip=0.off=0.dur=-5.pub=5 => -5
    close.comp=true.skip=0.off=0.dur=-5.pub=100 => -5
    close.comp=true.skip=0.off=0.dur=-5.pub=-3 => -5
    close.comp=true.skip=0.off=0.dur=-5.pub=nan => -5
    close.comp=true.skip=0.off=0.dur=-5.pub=inf => -5
    close.comp=true.skip=0.off=0.dur=-5.pub=2.5 => -5
    close.comp=true.skip=0.off=0.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=0.off=0.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=0.off=0.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=0.off=0.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=0.off=0.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=0.off=0.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=0.off=0.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=0.off=0.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=0.off=0.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=0.off=0.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=0.off=0.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=0.off=0.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=0.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=0.off=0.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=0.off=0.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=0.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=0.off=0.dur=nan.pub=0 => nan
    close.comp=true.skip=0.off=0.dur=nan.pub=1 => nan
    close.comp=true.skip=0.off=0.dur=nan.pub=5 => nan
    close.comp=true.skip=0.off=0.dur=nan.pub=100 => nan
    close.comp=true.skip=0.off=0.dur=nan.pub=-3 => nan
    close.comp=true.skip=0.off=0.dur=nan.pub=nan => nan
    close.comp=true.skip=0.off=0.dur=nan.pub=inf => nan
    close.comp=true.skip=0.off=0.dur=nan.pub=2.5 => nan
    close.comp=true.skip=0.off=0.dur=inf.pub=0 => inf
    close.comp=true.skip=0.off=0.dur=inf.pub=1 => inf
    close.comp=true.skip=0.off=0.dur=inf.pub=5 => inf
    close.comp=true.skip=0.off=0.dur=inf.pub=100 => inf
    close.comp=true.skip=0.off=0.dur=inf.pub=-3 => inf
    close.comp=true.skip=0.off=0.dur=inf.pub=nan => inf
    close.comp=true.skip=0.off=0.dur=inf.pub=inf => inf
    close.comp=true.skip=0.off=0.dur=inf.pub=2.5 => inf
    close.comp=true.skip=0.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=0.off=4.dur=nil.pub=1 => 0
    close.comp=true.skip=0.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=0.off=4.dur=nil.pub=100 => 0
    close.comp=true.skip=0.off=4.dur=nil.pub=-3 => 0
    close.comp=true.skip=0.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=0.off=4.dur=nil.pub=inf => 0
    close.comp=true.skip=0.off=4.dur=nil.pub=2.5 => 0
    close.comp=true.skip=0.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=0.off=4.dur=0.pub=1 => 0
    close.comp=true.skip=0.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=0.off=4.dur=0.pub=100 => 0
    close.comp=true.skip=0.off=4.dur=0.pub=-3 => 0
    close.comp=true.skip=0.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=0.off=4.dur=0.pub=inf => 0
    close.comp=true.skip=0.off=4.dur=0.pub=2.5 => 0
    close.comp=true.skip=0.off=4.dur=10.pub=0 => 10
    close.comp=true.skip=0.off=4.dur=10.pub=1 => 10
    close.comp=true.skip=0.off=4.dur=10.pub=5 => 10
    close.comp=true.skip=0.off=4.dur=10.pub=100 => 10
    close.comp=true.skip=0.off=4.dur=10.pub=-3 => 10
    close.comp=true.skip=0.off=4.dur=10.pub=nan => 10
    close.comp=true.skip=0.off=4.dur=10.pub=inf => 10
    close.comp=true.skip=0.off=4.dur=10.pub=2.5 => 10
    close.comp=true.skip=0.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=0.off=4.dur=60.pub=1 => 60
    close.comp=true.skip=0.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=0.off=4.dur=60.pub=100 => 60
    close.comp=true.skip=0.off=4.dur=60.pub=-3 => 60
    close.comp=true.skip=0.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=0.off=4.dur=60.pub=inf => 60
    close.comp=true.skip=0.off=4.dur=60.pub=2.5 => 60
    close.comp=true.skip=0.off=4.dur=-5.pub=0 => -5
    close.comp=true.skip=0.off=4.dur=-5.pub=1 => -5
    close.comp=true.skip=0.off=4.dur=-5.pub=5 => -5
    close.comp=true.skip=0.off=4.dur=-5.pub=100 => -5
    close.comp=true.skip=0.off=4.dur=-5.pub=-3 => -5
    close.comp=true.skip=0.off=4.dur=-5.pub=nan => -5
    close.comp=true.skip=0.off=4.dur=-5.pub=inf => -5
    close.comp=true.skip=0.off=4.dur=-5.pub=2.5 => -5
    close.comp=true.skip=0.off=4.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=0.off=4.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=0.off=4.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=0.off=4.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=0.off=4.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=0.off=4.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=0.off=4.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=0.off=4.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=0.off=4.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=0.off=4.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=0.off=4.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=0.off=4.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=0.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=0.off=4.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=0.off=4.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=0.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=0.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=0.off=4.dur=nan.pub=1 => nan
    close.comp=true.skip=0.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=0.off=4.dur=nan.pub=100 => nan
    close.comp=true.skip=0.off=4.dur=nan.pub=-3 => nan
    close.comp=true.skip=0.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=0.off=4.dur=nan.pub=inf => nan
    close.comp=true.skip=0.off=4.dur=nan.pub=2.5 => nan
    close.comp=true.skip=0.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=0.off=4.dur=inf.pub=1 => inf
    close.comp=true.skip=0.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=0.off=4.dur=inf.pub=100 => inf
    close.comp=true.skip=0.off=4.dur=inf.pub=-3 => inf
    close.comp=true.skip=0.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=0.off=4.dur=inf.pub=inf => inf
    close.comp=true.skip=0.off=4.dur=inf.pub=2.5 => inf
    close.comp=true.skip=0.off=20.dur=nil.pub=0 => 0
    close.comp=true.skip=0.off=20.dur=nil.pub=1 => 0
    close.comp=true.skip=0.off=20.dur=nil.pub=5 => 0
    close.comp=true.skip=0.off=20.dur=nil.pub=100 => 0
    close.comp=true.skip=0.off=20.dur=nil.pub=-3 => 0
    close.comp=true.skip=0.off=20.dur=nil.pub=nan => 0
    close.comp=true.skip=0.off=20.dur=nil.pub=inf => 0
    close.comp=true.skip=0.off=20.dur=nil.pub=2.5 => 0
    close.comp=true.skip=0.off=20.dur=0.pub=0 => 0
    close.comp=true.skip=0.off=20.dur=0.pub=1 => 0
    close.comp=true.skip=0.off=20.dur=0.pub=5 => 0
    close.comp=true.skip=0.off=20.dur=0.pub=100 => 0
    close.comp=true.skip=0.off=20.dur=0.pub=-3 => 0
    close.comp=true.skip=0.off=20.dur=0.pub=nan => 0
    close.comp=true.skip=0.off=20.dur=0.pub=inf => 0
    close.comp=true.skip=0.off=20.dur=0.pub=2.5 => 0
    close.comp=true.skip=0.off=20.dur=10.pub=0 => 10
    close.comp=true.skip=0.off=20.dur=10.pub=1 => 10
    close.comp=true.skip=0.off=20.dur=10.pub=5 => 10
    close.comp=true.skip=0.off=20.dur=10.pub=100 => 10
    close.comp=true.skip=0.off=20.dur=10.pub=-3 => 10
    close.comp=true.skip=0.off=20.dur=10.pub=nan => 10
    close.comp=true.skip=0.off=20.dur=10.pub=inf => 10
    close.comp=true.skip=0.off=20.dur=10.pub=2.5 => 10
    close.comp=true.skip=0.off=20.dur=60.pub=0 => 60
    close.comp=true.skip=0.off=20.dur=60.pub=1 => 60
    close.comp=true.skip=0.off=20.dur=60.pub=5 => 60
    close.comp=true.skip=0.off=20.dur=60.pub=100 => 60
    close.comp=true.skip=0.off=20.dur=60.pub=-3 => 60
    close.comp=true.skip=0.off=20.dur=60.pub=nan => 60
    close.comp=true.skip=0.off=20.dur=60.pub=inf => 60
    close.comp=true.skip=0.off=20.dur=60.pub=2.5 => 60
    close.comp=true.skip=0.off=20.dur=-5.pub=0 => -5
    close.comp=true.skip=0.off=20.dur=-5.pub=1 => -5
    close.comp=true.skip=0.off=20.dur=-5.pub=5 => -5
    close.comp=true.skip=0.off=20.dur=-5.pub=100 => -5
    close.comp=true.skip=0.off=20.dur=-5.pub=-3 => -5
    close.comp=true.skip=0.off=20.dur=-5.pub=nan => -5
    close.comp=true.skip=0.off=20.dur=-5.pub=inf => -5
    close.comp=true.skip=0.off=20.dur=-5.pub=2.5 => -5
    close.comp=true.skip=0.off=20.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=0.off=20.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=0.off=20.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=0.off=20.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=0.off=20.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=0.off=20.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=0.off=20.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=0.off=20.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=0.off=20.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=0.off=20.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=0.off=20.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=0.off=20.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=0.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=0.off=20.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=0.off=20.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=0.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=0.off=20.dur=nan.pub=0 => nan
    close.comp=true.skip=0.off=20.dur=nan.pub=1 => nan
    close.comp=true.skip=0.off=20.dur=nan.pub=5 => nan
    close.comp=true.skip=0.off=20.dur=nan.pub=100 => nan
    close.comp=true.skip=0.off=20.dur=nan.pub=-3 => nan
    close.comp=true.skip=0.off=20.dur=nan.pub=nan => nan
    close.comp=true.skip=0.off=20.dur=nan.pub=inf => nan
    close.comp=true.skip=0.off=20.dur=nan.pub=2.5 => nan
    close.comp=true.skip=0.off=20.dur=inf.pub=0 => inf
    close.comp=true.skip=0.off=20.dur=inf.pub=1 => inf
    close.comp=true.skip=0.off=20.dur=inf.pub=5 => inf
    close.comp=true.skip=0.off=20.dur=inf.pub=100 => inf
    close.comp=true.skip=0.off=20.dur=inf.pub=-3 => inf
    close.comp=true.skip=0.off=20.dur=inf.pub=nan => inf
    close.comp=true.skip=0.off=20.dur=inf.pub=inf => inf
    close.comp=true.skip=0.off=20.dur=inf.pub=2.5 => inf
    close.comp=true.skip=0.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=0.off=-1.dur=nil.pub=1 => 0
    close.comp=true.skip=0.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=0.off=-1.dur=nil.pub=100 => 0
    close.comp=true.skip=0.off=-1.dur=nil.pub=-3 => 0
    close.comp=true.skip=0.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=0.off=-1.dur=nil.pub=inf => 0
    close.comp=true.skip=0.off=-1.dur=nil.pub=2.5 => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=1 => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=100 => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=-3 => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=inf => 0
    close.comp=true.skip=0.off=-1.dur=0.pub=2.5 => 0
    close.comp=true.skip=0.off=-1.dur=10.pub=0 => 10
    close.comp=true.skip=0.off=-1.dur=10.pub=1 => 10
    close.comp=true.skip=0.off=-1.dur=10.pub=5 => 10
    close.comp=true.skip=0.off=-1.dur=10.pub=100 => 10
    close.comp=true.skip=0.off=-1.dur=10.pub=-3 => 10
    close.comp=true.skip=0.off=-1.dur=10.pub=nan => 10
    close.comp=true.skip=0.off=-1.dur=10.pub=inf => 10
    close.comp=true.skip=0.off=-1.dur=10.pub=2.5 => 10
    close.comp=true.skip=0.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=0.off=-1.dur=60.pub=1 => 60
    close.comp=true.skip=0.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=0.off=-1.dur=60.pub=100 => 60
    close.comp=true.skip=0.off=-1.dur=60.pub=-3 => 60
    close.comp=true.skip=0.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=0.off=-1.dur=60.pub=inf => 60
    close.comp=true.skip=0.off=-1.dur=60.pub=2.5 => 60
    close.comp=true.skip=0.off=-1.dur=-5.pub=0 => -5
    close.comp=true.skip=0.off=-1.dur=-5.pub=1 => -5
    close.comp=true.skip=0.off=-1.dur=-5.pub=5 => -5
    close.comp=true.skip=0.off=-1.dur=-5.pub=100 => -5
    close.comp=true.skip=0.off=-1.dur=-5.pub=-3 => -5
    close.comp=true.skip=0.off=-1.dur=-5.pub=nan => -5
    close.comp=true.skip=0.off=-1.dur=-5.pub=inf => -5
    close.comp=true.skip=0.off=-1.dur=-5.pub=2.5 => -5
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=0.off=-1.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=0.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=0.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=0.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=0.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=0.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=0.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=0.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=0.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=0.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=0.off=-1.dur=nan.pub=1 => nan
    close.comp=true.skip=0.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=0.off=-1.dur=nan.pub=100 => nan
    close.comp=true.skip=0.off=-1.dur=nan.pub=-3 => nan
    close.comp=true.skip=0.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=0.off=-1.dur=nan.pub=inf => nan
    close.comp=true.skip=0.off=-1.dur=nan.pub=2.5 => nan
    close.comp=true.skip=0.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=0.off=-1.dur=inf.pub=1 => inf
    close.comp=true.skip=0.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=0.off=-1.dur=inf.pub=100 => inf
    close.comp=true.skip=0.off=-1.dur=inf.pub=-3 => inf
    close.comp=true.skip=0.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=0.off=-1.dur=inf.pub=inf => inf
    close.comp=true.skip=0.off=-1.dur=inf.pub=2.5 => inf
    close.comp=true.skip=0.off=10.dur=nil.pub=0 => 0
    close.comp=true.skip=0.off=10.dur=nil.pub=1 => 0
    close.comp=true.skip=0.off=10.dur=nil.pub=5 => 0
    close.comp=true.skip=0.off=10.dur=nil.pub=100 => 0
    close.comp=true.skip=0.off=10.dur=nil.pub=-3 => 0
    close.comp=true.skip=0.off=10.dur=nil.pub=nan => 0
    close.comp=true.skip=0.off=10.dur=nil.pub=inf => 0
    close.comp=true.skip=0.off=10.dur=nil.pub=2.5 => 0
    close.comp=true.skip=0.off=10.dur=0.pub=0 => 0
    close.comp=true.skip=0.off=10.dur=0.pub=1 => 0
    close.comp=true.skip=0.off=10.dur=0.pub=5 => 0
    close.comp=true.skip=0.off=10.dur=0.pub=100 => 0
    close.comp=true.skip=0.off=10.dur=0.pub=-3 => 0
    close.comp=true.skip=0.off=10.dur=0.pub=nan => 0
    close.comp=true.skip=0.off=10.dur=0.pub=inf => 0
    close.comp=true.skip=0.off=10.dur=0.pub=2.5 => 0
    close.comp=true.skip=0.off=10.dur=10.pub=0 => 10
    close.comp=true.skip=0.off=10.dur=10.pub=1 => 10
    close.comp=true.skip=0.off=10.dur=10.pub=5 => 10
    close.comp=true.skip=0.off=10.dur=10.pub=100 => 10
    close.comp=true.skip=0.off=10.dur=10.pub=-3 => 10
    close.comp=true.skip=0.off=10.dur=10.pub=nan => 10
    close.comp=true.skip=0.off=10.dur=10.pub=inf => 10
    close.comp=true.skip=0.off=10.dur=10.pub=2.5 => 10
    close.comp=true.skip=0.off=10.dur=60.pub=0 => 60
    close.comp=true.skip=0.off=10.dur=60.pub=1 => 60
    close.comp=true.skip=0.off=10.dur=60.pub=5 => 60
    close.comp=true.skip=0.off=10.dur=60.pub=100 => 60
    close.comp=true.skip=0.off=10.dur=60.pub=-3 => 60
    close.comp=true.skip=0.off=10.dur=60.pub=nan => 60
    close.comp=true.skip=0.off=10.dur=60.pub=inf => 60
    close.comp=true.skip=0.off=10.dur=60.pub=2.5 => 60
    close.comp=true.skip=0.off=10.dur=-5.pub=0 => -5
    close.comp=true.skip=0.off=10.dur=-5.pub=1 => -5
    close.comp=true.skip=0.off=10.dur=-5.pub=5 => -5
    close.comp=true.skip=0.off=10.dur=-5.pub=100 => -5
    close.comp=true.skip=0.off=10.dur=-5.pub=-3 => -5
    close.comp=true.skip=0.off=10.dur=-5.pub=nan => -5
    close.comp=true.skip=0.off=10.dur=-5.pub=inf => -5
    close.comp=true.skip=0.off=10.dur=-5.pub=2.5 => -5
    close.comp=true.skip=0.off=10.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=0.off=10.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=0.off=10.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=0.off=10.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=0.off=10.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=0.off=10.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=0.off=10.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=0.off=10.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=0.off=10.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=0.off=10.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=0.off=10.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=0.off=10.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=0.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=0.off=10.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=0.off=10.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=0.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=0.off=10.dur=nan.pub=0 => nan
    close.comp=true.skip=0.off=10.dur=nan.pub=1 => nan
    close.comp=true.skip=0.off=10.dur=nan.pub=5 => nan
    close.comp=true.skip=0.off=10.dur=nan.pub=100 => nan
    close.comp=true.skip=0.off=10.dur=nan.pub=-3 => nan
    close.comp=true.skip=0.off=10.dur=nan.pub=nan => nan
    close.comp=true.skip=0.off=10.dur=nan.pub=inf => nan
    close.comp=true.skip=0.off=10.dur=nan.pub=2.5 => nan
    close.comp=true.skip=0.off=10.dur=inf.pub=0 => inf
    close.comp=true.skip=0.off=10.dur=inf.pub=1 => inf
    close.comp=true.skip=0.off=10.dur=inf.pub=5 => inf
    close.comp=true.skip=0.off=10.dur=inf.pub=100 => inf
    close.comp=true.skip=0.off=10.dur=inf.pub=-3 => inf
    close.comp=true.skip=0.off=10.dur=inf.pub=nan => inf
    close.comp=true.skip=0.off=10.dur=inf.pub=inf => inf
    close.comp=true.skip=0.off=10.dur=inf.pub=2.5 => inf
    close.comp=true.skip=5.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=1 => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=100 => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=-3 => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=inf => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=2.5 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=1 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=100 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=-3 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=inf => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=2.5 => 0
    close.comp=true.skip=5.off=nil.dur=10.pub=0 => 10
    close.comp=true.skip=5.off=nil.dur=10.pub=1 => 10
    close.comp=true.skip=5.off=nil.dur=10.pub=5 => 10
    close.comp=true.skip=5.off=nil.dur=10.pub=100 => 10
    close.comp=true.skip=5.off=nil.dur=10.pub=-3 => 10
    close.comp=true.skip=5.off=nil.dur=10.pub=nan => 10
    close.comp=true.skip=5.off=nil.dur=10.pub=inf => 10
    close.comp=true.skip=5.off=nil.dur=10.pub=2.5 => 10
    close.comp=true.skip=5.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=1 => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=100 => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=-3 => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=inf => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=2.5 => 60
    close.comp=true.skip=5.off=nil.dur=-5.pub=0 => -5
    close.comp=true.skip=5.off=nil.dur=-5.pub=1 => -5
    close.comp=true.skip=5.off=nil.dur=-5.pub=5 => -5
    close.comp=true.skip=5.off=nil.dur=-5.pub=100 => -5
    close.comp=true.skip=5.off=nil.dur=-5.pub=-3 => -5
    close.comp=true.skip=5.off=nil.dur=-5.pub=nan => -5
    close.comp=true.skip=5.off=nil.dur=-5.pub=inf => -5
    close.comp=true.skip=5.off=nil.dur=-5.pub=2.5 => -5
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=5.off=nil.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=5.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=5.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=5.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=5.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=5.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=5.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=5.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=5.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=5.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=1 => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=100 => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=-3 => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=inf => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=2.5 => nan
    close.comp=true.skip=5.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=1 => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=100 => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=-3 => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=inf => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=2.5 => inf
    close.comp=true.skip=5.off=0.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=0.dur=nil.pub=1 => 0
    close.comp=true.skip=5.off=0.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=0.dur=nil.pub=100 => 0
    close.comp=true.skip=5.off=0.dur=nil.pub=-3 => 0
    close.comp=true.skip=5.off=0.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=0.dur=nil.pub=inf => 0
    close.comp=true.skip=5.off=0.dur=nil.pub=2.5 => 0
    close.comp=true.skip=5.off=0.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=0.dur=0.pub=1 => 0
    close.comp=true.skip=5.off=0.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=0.dur=0.pub=100 => 0
    close.comp=true.skip=5.off=0.dur=0.pub=-3 => 0
    close.comp=true.skip=5.off=0.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=0.dur=0.pub=inf => 0
    close.comp=true.skip=5.off=0.dur=0.pub=2.5 => 0
    close.comp=true.skip=5.off=0.dur=10.pub=0 => 10
    close.comp=true.skip=5.off=0.dur=10.pub=1 => 10
    close.comp=true.skip=5.off=0.dur=10.pub=5 => 10
    close.comp=true.skip=5.off=0.dur=10.pub=100 => 10
    close.comp=true.skip=5.off=0.dur=10.pub=-3 => 10
    close.comp=true.skip=5.off=0.dur=10.pub=nan => 10
    close.comp=true.skip=5.off=0.dur=10.pub=inf => 10
    close.comp=true.skip=5.off=0.dur=10.pub=2.5 => 10
    close.comp=true.skip=5.off=0.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=0.dur=60.pub=1 => 60
    close.comp=true.skip=5.off=0.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=0.dur=60.pub=100 => 60
    close.comp=true.skip=5.off=0.dur=60.pub=-3 => 60
    close.comp=true.skip=5.off=0.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=0.dur=60.pub=inf => 60
    close.comp=true.skip=5.off=0.dur=60.pub=2.5 => 60
    close.comp=true.skip=5.off=0.dur=-5.pub=0 => -5
    close.comp=true.skip=5.off=0.dur=-5.pub=1 => -5
    close.comp=true.skip=5.off=0.dur=-5.pub=5 => -5
    close.comp=true.skip=5.off=0.dur=-5.pub=100 => -5
    close.comp=true.skip=5.off=0.dur=-5.pub=-3 => -5
    close.comp=true.skip=5.off=0.dur=-5.pub=nan => -5
    close.comp=true.skip=5.off=0.dur=-5.pub=inf => -5
    close.comp=true.skip=5.off=0.dur=-5.pub=2.5 => -5
    close.comp=true.skip=5.off=0.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=5.off=0.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=5.off=0.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=5.off=0.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=5.off=0.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=5.off=0.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=5.off=0.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=5.off=0.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=5.off=0.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=5.off=0.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=5.off=0.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=5.off=0.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=5.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=5.off=0.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=5.off=0.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=5.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=5.off=0.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=0.dur=nan.pub=1 => nan
    close.comp=true.skip=5.off=0.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=0.dur=nan.pub=100 => nan
    close.comp=true.skip=5.off=0.dur=nan.pub=-3 => nan
    close.comp=true.skip=5.off=0.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=0.dur=nan.pub=inf => nan
    close.comp=true.skip=5.off=0.dur=nan.pub=2.5 => nan
    close.comp=true.skip=5.off=0.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=0.dur=inf.pub=1 => inf
    close.comp=true.skip=5.off=0.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=0.dur=inf.pub=100 => inf
    close.comp=true.skip=5.off=0.dur=inf.pub=-3 => inf
    close.comp=true.skip=5.off=0.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=0.dur=inf.pub=inf => inf
    close.comp=true.skip=5.off=0.dur=inf.pub=2.5 => inf
    close.comp=true.skip=5.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=1 => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=100 => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=-3 => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=inf => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=2.5 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=1 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=100 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=-3 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=4.dur=0.pub=inf => 0
    close.comp=true.skip=5.off=4.dur=0.pub=2.5 => 0
    close.comp=true.skip=5.off=4.dur=10.pub=0 => 10
    close.comp=true.skip=5.off=4.dur=10.pub=1 => 10
    close.comp=true.skip=5.off=4.dur=10.pub=5 => 10
    close.comp=true.skip=5.off=4.dur=10.pub=100 => 10
    close.comp=true.skip=5.off=4.dur=10.pub=-3 => 10
    close.comp=true.skip=5.off=4.dur=10.pub=nan => 10
    close.comp=true.skip=5.off=4.dur=10.pub=inf => 10
    close.comp=true.skip=5.off=4.dur=10.pub=2.5 => 10
    close.comp=true.skip=5.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=4.dur=60.pub=1 => 60
    close.comp=true.skip=5.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=4.dur=60.pub=100 => 60
    close.comp=true.skip=5.off=4.dur=60.pub=-3 => 60
    close.comp=true.skip=5.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=4.dur=60.pub=inf => 60
    close.comp=true.skip=5.off=4.dur=60.pub=2.5 => 60
    close.comp=true.skip=5.off=4.dur=-5.pub=0 => -5
    close.comp=true.skip=5.off=4.dur=-5.pub=1 => -5
    close.comp=true.skip=5.off=4.dur=-5.pub=5 => -5
    close.comp=true.skip=5.off=4.dur=-5.pub=100 => -5
    close.comp=true.skip=5.off=4.dur=-5.pub=-3 => -5
    close.comp=true.skip=5.off=4.dur=-5.pub=nan => -5
    close.comp=true.skip=5.off=4.dur=-5.pub=inf => -5
    close.comp=true.skip=5.off=4.dur=-5.pub=2.5 => -5
    close.comp=true.skip=5.off=4.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=5.off=4.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=5.off=4.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=5.off=4.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=5.off=4.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=5.off=4.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=5.off=4.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=5.off=4.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=5.off=4.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=5.off=4.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=5.off=4.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=5.off=4.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=5.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=5.off=4.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=5.off=4.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=5.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=5.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=1 => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=100 => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=-3 => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=inf => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=2.5 => nan
    close.comp=true.skip=5.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=1 => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=100 => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=-3 => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=inf => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=2.5 => inf
    close.comp=true.skip=5.off=20.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=20.dur=nil.pub=1 => 0
    close.comp=true.skip=5.off=20.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=20.dur=nil.pub=100 => 0
    close.comp=true.skip=5.off=20.dur=nil.pub=-3 => 0
    close.comp=true.skip=5.off=20.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=20.dur=nil.pub=inf => 0
    close.comp=true.skip=5.off=20.dur=nil.pub=2.5 => 0
    close.comp=true.skip=5.off=20.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=20.dur=0.pub=1 => 0
    close.comp=true.skip=5.off=20.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=20.dur=0.pub=100 => 0
    close.comp=true.skip=5.off=20.dur=0.pub=-3 => 0
    close.comp=true.skip=5.off=20.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=20.dur=0.pub=inf => 0
    close.comp=true.skip=5.off=20.dur=0.pub=2.5 => 0
    close.comp=true.skip=5.off=20.dur=10.pub=0 => 10
    close.comp=true.skip=5.off=20.dur=10.pub=1 => 10
    close.comp=true.skip=5.off=20.dur=10.pub=5 => 10
    close.comp=true.skip=5.off=20.dur=10.pub=100 => 10
    close.comp=true.skip=5.off=20.dur=10.pub=-3 => 10
    close.comp=true.skip=5.off=20.dur=10.pub=nan => 10
    close.comp=true.skip=5.off=20.dur=10.pub=inf => 10
    close.comp=true.skip=5.off=20.dur=10.pub=2.5 => 10
    close.comp=true.skip=5.off=20.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=20.dur=60.pub=1 => 60
    close.comp=true.skip=5.off=20.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=20.dur=60.pub=100 => 60
    close.comp=true.skip=5.off=20.dur=60.pub=-3 => 60
    close.comp=true.skip=5.off=20.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=20.dur=60.pub=inf => 60
    close.comp=true.skip=5.off=20.dur=60.pub=2.5 => 60
    close.comp=true.skip=5.off=20.dur=-5.pub=0 => -5
    close.comp=true.skip=5.off=20.dur=-5.pub=1 => -5
    close.comp=true.skip=5.off=20.dur=-5.pub=5 => -5
    close.comp=true.skip=5.off=20.dur=-5.pub=100 => -5
    close.comp=true.skip=5.off=20.dur=-5.pub=-3 => -5
    close.comp=true.skip=5.off=20.dur=-5.pub=nan => -5
    close.comp=true.skip=5.off=20.dur=-5.pub=inf => -5
    close.comp=true.skip=5.off=20.dur=-5.pub=2.5 => -5
    close.comp=true.skip=5.off=20.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=5.off=20.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=5.off=20.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=5.off=20.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=5.off=20.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=5.off=20.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=5.off=20.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=5.off=20.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=5.off=20.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=5.off=20.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=5.off=20.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=5.off=20.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=5.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=5.off=20.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=5.off=20.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=5.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=5.off=20.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=20.dur=nan.pub=1 => nan
    close.comp=true.skip=5.off=20.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=20.dur=nan.pub=100 => nan
    close.comp=true.skip=5.off=20.dur=nan.pub=-3 => nan
    close.comp=true.skip=5.off=20.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=20.dur=nan.pub=inf => nan
    close.comp=true.skip=5.off=20.dur=nan.pub=2.5 => nan
    close.comp=true.skip=5.off=20.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=20.dur=inf.pub=1 => inf
    close.comp=true.skip=5.off=20.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=20.dur=inf.pub=100 => inf
    close.comp=true.skip=5.off=20.dur=inf.pub=-3 => inf
    close.comp=true.skip=5.off=20.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=20.dur=inf.pub=inf => inf
    close.comp=true.skip=5.off=20.dur=inf.pub=2.5 => inf
    close.comp=true.skip=5.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=1 => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=100 => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=-3 => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=inf => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=2.5 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=1 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=100 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=-3 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=inf => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=2.5 => 0
    close.comp=true.skip=5.off=-1.dur=10.pub=0 => 10
    close.comp=true.skip=5.off=-1.dur=10.pub=1 => 10
    close.comp=true.skip=5.off=-1.dur=10.pub=5 => 10
    close.comp=true.skip=5.off=-1.dur=10.pub=100 => 10
    close.comp=true.skip=5.off=-1.dur=10.pub=-3 => 10
    close.comp=true.skip=5.off=-1.dur=10.pub=nan => 10
    close.comp=true.skip=5.off=-1.dur=10.pub=inf => 10
    close.comp=true.skip=5.off=-1.dur=10.pub=2.5 => 10
    close.comp=true.skip=5.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=1 => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=100 => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=-3 => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=inf => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=2.5 => 60
    close.comp=true.skip=5.off=-1.dur=-5.pub=0 => -5
    close.comp=true.skip=5.off=-1.dur=-5.pub=1 => -5
    close.comp=true.skip=5.off=-1.dur=-5.pub=5 => -5
    close.comp=true.skip=5.off=-1.dur=-5.pub=100 => -5
    close.comp=true.skip=5.off=-1.dur=-5.pub=-3 => -5
    close.comp=true.skip=5.off=-1.dur=-5.pub=nan => -5
    close.comp=true.skip=5.off=-1.dur=-5.pub=inf => -5
    close.comp=true.skip=5.off=-1.dur=-5.pub=2.5 => -5
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=5.off=-1.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=5.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=5.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=5.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=5.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=5.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=5.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=5.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=5.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=5.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=1 => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=100 => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=-3 => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=inf => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=2.5 => nan
    close.comp=true.skip=5.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=1 => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=100 => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=-3 => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=inf => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=2.5 => inf
    close.comp=true.skip=5.off=10.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=10.dur=nil.pub=1 => 0
    close.comp=true.skip=5.off=10.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=10.dur=nil.pub=100 => 0
    close.comp=true.skip=5.off=10.dur=nil.pub=-3 => 0
    close.comp=true.skip=5.off=10.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=10.dur=nil.pub=inf => 0
    close.comp=true.skip=5.off=10.dur=nil.pub=2.5 => 0
    close.comp=true.skip=5.off=10.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=10.dur=0.pub=1 => 0
    close.comp=true.skip=5.off=10.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=10.dur=0.pub=100 => 0
    close.comp=true.skip=5.off=10.dur=0.pub=-3 => 0
    close.comp=true.skip=5.off=10.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=10.dur=0.pub=inf => 0
    close.comp=true.skip=5.off=10.dur=0.pub=2.5 => 0
    close.comp=true.skip=5.off=10.dur=10.pub=0 => 10
    close.comp=true.skip=5.off=10.dur=10.pub=1 => 10
    close.comp=true.skip=5.off=10.dur=10.pub=5 => 10
    close.comp=true.skip=5.off=10.dur=10.pub=100 => 10
    close.comp=true.skip=5.off=10.dur=10.pub=-3 => 10
    close.comp=true.skip=5.off=10.dur=10.pub=nan => 10
    close.comp=true.skip=5.off=10.dur=10.pub=inf => 10
    close.comp=true.skip=5.off=10.dur=10.pub=2.5 => 10
    close.comp=true.skip=5.off=10.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=10.dur=60.pub=1 => 60
    close.comp=true.skip=5.off=10.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=10.dur=60.pub=100 => 60
    close.comp=true.skip=5.off=10.dur=60.pub=-3 => 60
    close.comp=true.skip=5.off=10.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=10.dur=60.pub=inf => 60
    close.comp=true.skip=5.off=10.dur=60.pub=2.5 => 60
    close.comp=true.skip=5.off=10.dur=-5.pub=0 => -5
    close.comp=true.skip=5.off=10.dur=-5.pub=1 => -5
    close.comp=true.skip=5.off=10.dur=-5.pub=5 => -5
    close.comp=true.skip=5.off=10.dur=-5.pub=100 => -5
    close.comp=true.skip=5.off=10.dur=-5.pub=-3 => -5
    close.comp=true.skip=5.off=10.dur=-5.pub=nan => -5
    close.comp=true.skip=5.off=10.dur=-5.pub=inf => -5
    close.comp=true.skip=5.off=10.dur=-5.pub=2.5 => -5
    close.comp=true.skip=5.off=10.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=5.off=10.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=5.off=10.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=5.off=10.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=5.off=10.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=5.off=10.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=5.off=10.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=5.off=10.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=5.off=10.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=5.off=10.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=5.off=10.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=5.off=10.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=5.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=5.off=10.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=5.off=10.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=5.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=5.off=10.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=10.dur=nan.pub=1 => nan
    close.comp=true.skip=5.off=10.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=10.dur=nan.pub=100 => nan
    close.comp=true.skip=5.off=10.dur=nan.pub=-3 => nan
    close.comp=true.skip=5.off=10.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=10.dur=nan.pub=inf => nan
    close.comp=true.skip=5.off=10.dur=nan.pub=2.5 => nan
    close.comp=true.skip=5.off=10.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=10.dur=inf.pub=1 => inf
    close.comp=true.skip=5.off=10.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=10.dur=inf.pub=100 => inf
    close.comp=true.skip=5.off=10.dur=inf.pub=-3 => inf
    close.comp=true.skip=5.off=10.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=10.dur=inf.pub=inf => inf
    close.comp=true.skip=5.off=10.dur=inf.pub=2.5 => inf
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=1 => 0
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=100 => 0
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=-3 => 0
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=inf => 0
    close.comp=true.skip=1000000.off=nil.dur=nil.pub=2.5 => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=1 => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=100 => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=-3 => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=inf => 0
    close.comp=true.skip=1000000.off=nil.dur=0.pub=2.5 => 0
    close.comp=true.skip=1000000.off=nil.dur=10.pub=0 => 10
    close.comp=true.skip=1000000.off=nil.dur=10.pub=1 => 10
    close.comp=true.skip=1000000.off=nil.dur=10.pub=5 => 10
    close.comp=true.skip=1000000.off=nil.dur=10.pub=100 => 10
    close.comp=true.skip=1000000.off=nil.dur=10.pub=-3 => 10
    close.comp=true.skip=1000000.off=nil.dur=10.pub=nan => 10
    close.comp=true.skip=1000000.off=nil.dur=10.pub=inf => 10
    close.comp=true.skip=1000000.off=nil.dur=10.pub=2.5 => 10
    close.comp=true.skip=1000000.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=1000000.off=nil.dur=60.pub=1 => 60
    close.comp=true.skip=1000000.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=1000000.off=nil.dur=60.pub=100 => 60
    close.comp=true.skip=1000000.off=nil.dur=60.pub=-3 => 60
    close.comp=true.skip=1000000.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=1000000.off=nil.dur=60.pub=inf => 60
    close.comp=true.skip=1000000.off=nil.dur=60.pub=2.5 => 60
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=0 => -5
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=1 => -5
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=5 => -5
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=100 => -5
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=-3 => -5
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=nan => -5
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=inf => -5
    close.comp=true.skip=1000000.off=nil.dur=-5.pub=2.5 => -5
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=1000000.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=1 => nan
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=100 => nan
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=-3 => nan
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=inf => nan
    close.comp=true.skip=1000000.off=nil.dur=nan.pub=2.5 => nan
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=1 => inf
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=100 => inf
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=-3 => inf
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=inf => inf
    close.comp=true.skip=1000000.off=nil.dur=inf.pub=2.5 => inf
    close.comp=true.skip=1000000.off=0.dur=nil.pub=0 => 0
    close.comp=true.skip=1000000.off=0.dur=nil.pub=1 => 0
    close.comp=true.skip=1000000.off=0.dur=nil.pub=5 => 0
    close.comp=true.skip=1000000.off=0.dur=nil.pub=100 => 0
    close.comp=true.skip=1000000.off=0.dur=nil.pub=-3 => 0
    close.comp=true.skip=1000000.off=0.dur=nil.pub=nan => 0
    close.comp=true.skip=1000000.off=0.dur=nil.pub=inf => 0
    close.comp=true.skip=1000000.off=0.dur=nil.pub=2.5 => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=0 => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=1 => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=5 => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=100 => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=-3 => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=nan => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=inf => 0
    close.comp=true.skip=1000000.off=0.dur=0.pub=2.5 => 0
    close.comp=true.skip=1000000.off=0.dur=10.pub=0 => 10
    close.comp=true.skip=1000000.off=0.dur=10.pub=1 => 10
    close.comp=true.skip=1000000.off=0.dur=10.pub=5 => 10
    close.comp=true.skip=1000000.off=0.dur=10.pub=100 => 10
    close.comp=true.skip=1000000.off=0.dur=10.pub=-3 => 10
    close.comp=true.skip=1000000.off=0.dur=10.pub=nan => 10
    close.comp=true.skip=1000000.off=0.dur=10.pub=inf => 10
    close.comp=true.skip=1000000.off=0.dur=10.pub=2.5 => 10
    close.comp=true.skip=1000000.off=0.dur=60.pub=0 => 60
    close.comp=true.skip=1000000.off=0.dur=60.pub=1 => 60
    close.comp=true.skip=1000000.off=0.dur=60.pub=5 => 60
    close.comp=true.skip=1000000.off=0.dur=60.pub=100 => 60
    close.comp=true.skip=1000000.off=0.dur=60.pub=-3 => 60
    close.comp=true.skip=1000000.off=0.dur=60.pub=nan => 60
    close.comp=true.skip=1000000.off=0.dur=60.pub=inf => 60
    close.comp=true.skip=1000000.off=0.dur=60.pub=2.5 => 60
    close.comp=true.skip=1000000.off=0.dur=-5.pub=0 => -5
    close.comp=true.skip=1000000.off=0.dur=-5.pub=1 => -5
    close.comp=true.skip=1000000.off=0.dur=-5.pub=5 => -5
    close.comp=true.skip=1000000.off=0.dur=-5.pub=100 => -5
    close.comp=true.skip=1000000.off=0.dur=-5.pub=-3 => -5
    close.comp=true.skip=1000000.off=0.dur=-5.pub=nan => -5
    close.comp=true.skip=1000000.off=0.dur=-5.pub=inf => -5
    close.comp=true.skip=1000000.off=0.dur=-5.pub=2.5 => -5
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=1000000.off=0.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=1000000.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=1000000.off=0.dur=nan.pub=0 => nan
    close.comp=true.skip=1000000.off=0.dur=nan.pub=1 => nan
    close.comp=true.skip=1000000.off=0.dur=nan.pub=5 => nan
    close.comp=true.skip=1000000.off=0.dur=nan.pub=100 => nan
    close.comp=true.skip=1000000.off=0.dur=nan.pub=-3 => nan
    close.comp=true.skip=1000000.off=0.dur=nan.pub=nan => nan
    close.comp=true.skip=1000000.off=0.dur=nan.pub=inf => nan
    close.comp=true.skip=1000000.off=0.dur=nan.pub=2.5 => nan
    close.comp=true.skip=1000000.off=0.dur=inf.pub=0 => inf
    close.comp=true.skip=1000000.off=0.dur=inf.pub=1 => inf
    close.comp=true.skip=1000000.off=0.dur=inf.pub=5 => inf
    close.comp=true.skip=1000000.off=0.dur=inf.pub=100 => inf
    close.comp=true.skip=1000000.off=0.dur=inf.pub=-3 => inf
    close.comp=true.skip=1000000.off=0.dur=inf.pub=nan => inf
    close.comp=true.skip=1000000.off=0.dur=inf.pub=inf => inf
    close.comp=true.skip=1000000.off=0.dur=inf.pub=2.5 => inf
    close.comp=true.skip=1000000.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=1000000.off=4.dur=nil.pub=1 => 0
    close.comp=true.skip=1000000.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=1000000.off=4.dur=nil.pub=100 => 0
    close.comp=true.skip=1000000.off=4.dur=nil.pub=-3 => 0
    close.comp=true.skip=1000000.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=1000000.off=4.dur=nil.pub=inf => 0
    close.comp=true.skip=1000000.off=4.dur=nil.pub=2.5 => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=1 => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=100 => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=-3 => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=inf => 0
    close.comp=true.skip=1000000.off=4.dur=0.pub=2.5 => 0
    close.comp=true.skip=1000000.off=4.dur=10.pub=0 => 10
    close.comp=true.skip=1000000.off=4.dur=10.pub=1 => 10
    close.comp=true.skip=1000000.off=4.dur=10.pub=5 => 10
    close.comp=true.skip=1000000.off=4.dur=10.pub=100 => 10
    close.comp=true.skip=1000000.off=4.dur=10.pub=-3 => 10
    close.comp=true.skip=1000000.off=4.dur=10.pub=nan => 10
    close.comp=true.skip=1000000.off=4.dur=10.pub=inf => 10
    close.comp=true.skip=1000000.off=4.dur=10.pub=2.5 => 10
    close.comp=true.skip=1000000.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=1000000.off=4.dur=60.pub=1 => 60
    close.comp=true.skip=1000000.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=1000000.off=4.dur=60.pub=100 => 60
    close.comp=true.skip=1000000.off=4.dur=60.pub=-3 => 60
    close.comp=true.skip=1000000.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=1000000.off=4.dur=60.pub=inf => 60
    close.comp=true.skip=1000000.off=4.dur=60.pub=2.5 => 60
    close.comp=true.skip=1000000.off=4.dur=-5.pub=0 => -5
    close.comp=true.skip=1000000.off=4.dur=-5.pub=1 => -5
    close.comp=true.skip=1000000.off=4.dur=-5.pub=5 => -5
    close.comp=true.skip=1000000.off=4.dur=-5.pub=100 => -5
    close.comp=true.skip=1000000.off=4.dur=-5.pub=-3 => -5
    close.comp=true.skip=1000000.off=4.dur=-5.pub=nan => -5
    close.comp=true.skip=1000000.off=4.dur=-5.pub=inf => -5
    close.comp=true.skip=1000000.off=4.dur=-5.pub=2.5 => -5
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=1000000.off=4.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=1000000.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=1000000.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=1000000.off=4.dur=nan.pub=1 => nan
    close.comp=true.skip=1000000.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=1000000.off=4.dur=nan.pub=100 => nan
    close.comp=true.skip=1000000.off=4.dur=nan.pub=-3 => nan
    close.comp=true.skip=1000000.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=1000000.off=4.dur=nan.pub=inf => nan
    close.comp=true.skip=1000000.off=4.dur=nan.pub=2.5 => nan
    close.comp=true.skip=1000000.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=1000000.off=4.dur=inf.pub=1 => inf
    close.comp=true.skip=1000000.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=1000000.off=4.dur=inf.pub=100 => inf
    close.comp=true.skip=1000000.off=4.dur=inf.pub=-3 => inf
    close.comp=true.skip=1000000.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=1000000.off=4.dur=inf.pub=inf => inf
    close.comp=true.skip=1000000.off=4.dur=inf.pub=2.5 => inf
    close.comp=true.skip=1000000.off=20.dur=nil.pub=0 => 0
    close.comp=true.skip=1000000.off=20.dur=nil.pub=1 => 0
    close.comp=true.skip=1000000.off=20.dur=nil.pub=5 => 0
    close.comp=true.skip=1000000.off=20.dur=nil.pub=100 => 0
    close.comp=true.skip=1000000.off=20.dur=nil.pub=-3 => 0
    close.comp=true.skip=1000000.off=20.dur=nil.pub=nan => 0
    close.comp=true.skip=1000000.off=20.dur=nil.pub=inf => 0
    close.comp=true.skip=1000000.off=20.dur=nil.pub=2.5 => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=0 => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=1 => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=5 => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=100 => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=-3 => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=nan => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=inf => 0
    close.comp=true.skip=1000000.off=20.dur=0.pub=2.5 => 0
    close.comp=true.skip=1000000.off=20.dur=10.pub=0 => 10
    close.comp=true.skip=1000000.off=20.dur=10.pub=1 => 10
    close.comp=true.skip=1000000.off=20.dur=10.pub=5 => 10
    close.comp=true.skip=1000000.off=20.dur=10.pub=100 => 10
    close.comp=true.skip=1000000.off=20.dur=10.pub=-3 => 10
    close.comp=true.skip=1000000.off=20.dur=10.pub=nan => 10
    close.comp=true.skip=1000000.off=20.dur=10.pub=inf => 10
    close.comp=true.skip=1000000.off=20.dur=10.pub=2.5 => 10
    close.comp=true.skip=1000000.off=20.dur=60.pub=0 => 60
    close.comp=true.skip=1000000.off=20.dur=60.pub=1 => 60
    close.comp=true.skip=1000000.off=20.dur=60.pub=5 => 60
    close.comp=true.skip=1000000.off=20.dur=60.pub=100 => 60
    close.comp=true.skip=1000000.off=20.dur=60.pub=-3 => 60
    close.comp=true.skip=1000000.off=20.dur=60.pub=nan => 60
    close.comp=true.skip=1000000.off=20.dur=60.pub=inf => 60
    close.comp=true.skip=1000000.off=20.dur=60.pub=2.5 => 60
    close.comp=true.skip=1000000.off=20.dur=-5.pub=0 => -5
    close.comp=true.skip=1000000.off=20.dur=-5.pub=1 => -5
    close.comp=true.skip=1000000.off=20.dur=-5.pub=5 => -5
    close.comp=true.skip=1000000.off=20.dur=-5.pub=100 => -5
    close.comp=true.skip=1000000.off=20.dur=-5.pub=-3 => -5
    close.comp=true.skip=1000000.off=20.dur=-5.pub=nan => -5
    close.comp=true.skip=1000000.off=20.dur=-5.pub=inf => -5
    close.comp=true.skip=1000000.off=20.dur=-5.pub=2.5 => -5
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=1000000.off=20.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=1000000.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=1000000.off=20.dur=nan.pub=0 => nan
    close.comp=true.skip=1000000.off=20.dur=nan.pub=1 => nan
    close.comp=true.skip=1000000.off=20.dur=nan.pub=5 => nan
    close.comp=true.skip=1000000.off=20.dur=nan.pub=100 => nan
    close.comp=true.skip=1000000.off=20.dur=nan.pub=-3 => nan
    close.comp=true.skip=1000000.off=20.dur=nan.pub=nan => nan
    close.comp=true.skip=1000000.off=20.dur=nan.pub=inf => nan
    close.comp=true.skip=1000000.off=20.dur=nan.pub=2.5 => nan
    close.comp=true.skip=1000000.off=20.dur=inf.pub=0 => inf
    close.comp=true.skip=1000000.off=20.dur=inf.pub=1 => inf
    close.comp=true.skip=1000000.off=20.dur=inf.pub=5 => inf
    close.comp=true.skip=1000000.off=20.dur=inf.pub=100 => inf
    close.comp=true.skip=1000000.off=20.dur=inf.pub=-3 => inf
    close.comp=true.skip=1000000.off=20.dur=inf.pub=nan => inf
    close.comp=true.skip=1000000.off=20.dur=inf.pub=inf => inf
    close.comp=true.skip=1000000.off=20.dur=inf.pub=2.5 => inf
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=1 => 0
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=100 => 0
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=-3 => 0
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=inf => 0
    close.comp=true.skip=1000000.off=-1.dur=nil.pub=2.5 => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=1 => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=100 => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=-3 => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=inf => 0
    close.comp=true.skip=1000000.off=-1.dur=0.pub=2.5 => 0
    close.comp=true.skip=1000000.off=-1.dur=10.pub=0 => 10
    close.comp=true.skip=1000000.off=-1.dur=10.pub=1 => 10
    close.comp=true.skip=1000000.off=-1.dur=10.pub=5 => 10
    close.comp=true.skip=1000000.off=-1.dur=10.pub=100 => 10
    close.comp=true.skip=1000000.off=-1.dur=10.pub=-3 => 10
    close.comp=true.skip=1000000.off=-1.dur=10.pub=nan => 10
    close.comp=true.skip=1000000.off=-1.dur=10.pub=inf => 10
    close.comp=true.skip=1000000.off=-1.dur=10.pub=2.5 => 10
    close.comp=true.skip=1000000.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=1000000.off=-1.dur=60.pub=1 => 60
    close.comp=true.skip=1000000.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=1000000.off=-1.dur=60.pub=100 => 60
    close.comp=true.skip=1000000.off=-1.dur=60.pub=-3 => 60
    close.comp=true.skip=1000000.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=1000000.off=-1.dur=60.pub=inf => 60
    close.comp=true.skip=1000000.off=-1.dur=60.pub=2.5 => 60
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=0 => -5
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=1 => -5
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=5 => -5
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=100 => -5
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=-3 => -5
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=nan => -5
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=inf => -5
    close.comp=true.skip=1000000.off=-1.dur=-5.pub=2.5 => -5
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=1000000.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=1 => nan
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=100 => nan
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=-3 => nan
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=inf => nan
    close.comp=true.skip=1000000.off=-1.dur=nan.pub=2.5 => nan
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=1 => inf
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=100 => inf
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=-3 => inf
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=inf => inf
    close.comp=true.skip=1000000.off=-1.dur=inf.pub=2.5 => inf
    close.comp=true.skip=1000000.off=10.dur=nil.pub=0 => 0
    close.comp=true.skip=1000000.off=10.dur=nil.pub=1 => 0
    close.comp=true.skip=1000000.off=10.dur=nil.pub=5 => 0
    close.comp=true.skip=1000000.off=10.dur=nil.pub=100 => 0
    close.comp=true.skip=1000000.off=10.dur=nil.pub=-3 => 0
    close.comp=true.skip=1000000.off=10.dur=nil.pub=nan => 0
    close.comp=true.skip=1000000.off=10.dur=nil.pub=inf => 0
    close.comp=true.skip=1000000.off=10.dur=nil.pub=2.5 => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=0 => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=1 => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=5 => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=100 => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=-3 => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=nan => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=inf => 0
    close.comp=true.skip=1000000.off=10.dur=0.pub=2.5 => 0
    close.comp=true.skip=1000000.off=10.dur=10.pub=0 => 10
    close.comp=true.skip=1000000.off=10.dur=10.pub=1 => 10
    close.comp=true.skip=1000000.off=10.dur=10.pub=5 => 10
    close.comp=true.skip=1000000.off=10.dur=10.pub=100 => 10
    close.comp=true.skip=1000000.off=10.dur=10.pub=-3 => 10
    close.comp=true.skip=1000000.off=10.dur=10.pub=nan => 10
    close.comp=true.skip=1000000.off=10.dur=10.pub=inf => 10
    close.comp=true.skip=1000000.off=10.dur=10.pub=2.5 => 10
    close.comp=true.skip=1000000.off=10.dur=60.pub=0 => 60
    close.comp=true.skip=1000000.off=10.dur=60.pub=1 => 60
    close.comp=true.skip=1000000.off=10.dur=60.pub=5 => 60
    close.comp=true.skip=1000000.off=10.dur=60.pub=100 => 60
    close.comp=true.skip=1000000.off=10.dur=60.pub=-3 => 60
    close.comp=true.skip=1000000.off=10.dur=60.pub=nan => 60
    close.comp=true.skip=1000000.off=10.dur=60.pub=inf => 60
    close.comp=true.skip=1000000.off=10.dur=60.pub=2.5 => 60
    close.comp=true.skip=1000000.off=10.dur=-5.pub=0 => -5
    close.comp=true.skip=1000000.off=10.dur=-5.pub=1 => -5
    close.comp=true.skip=1000000.off=10.dur=-5.pub=5 => -5
    close.comp=true.skip=1000000.off=10.dur=-5.pub=100 => -5
    close.comp=true.skip=1000000.off=10.dur=-5.pub=-3 => -5
    close.comp=true.skip=1000000.off=10.dur=-5.pub=nan => -5
    close.comp=true.skip=1000000.off=10.dur=-5.pub=inf => -5
    close.comp=true.skip=1000000.off=10.dur=-5.pub=2.5 => -5
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=1000000.off=10.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=1000000.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=1000000.off=10.dur=nan.pub=0 => nan
    close.comp=true.skip=1000000.off=10.dur=nan.pub=1 => nan
    close.comp=true.skip=1000000.off=10.dur=nan.pub=5 => nan
    close.comp=true.skip=1000000.off=10.dur=nan.pub=100 => nan
    close.comp=true.skip=1000000.off=10.dur=nan.pub=-3 => nan
    close.comp=true.skip=1000000.off=10.dur=nan.pub=nan => nan
    close.comp=true.skip=1000000.off=10.dur=nan.pub=inf => nan
    close.comp=true.skip=1000000.off=10.dur=nan.pub=2.5 => nan
    close.comp=true.skip=1000000.off=10.dur=inf.pub=0 => inf
    close.comp=true.skip=1000000.off=10.dur=inf.pub=1 => inf
    close.comp=true.skip=1000000.off=10.dur=inf.pub=5 => inf
    close.comp=true.skip=1000000.off=10.dur=inf.pub=100 => inf
    close.comp=true.skip=1000000.off=10.dur=inf.pub=-3 => inf
    close.comp=true.skip=1000000.off=10.dur=inf.pub=nan => inf
    close.comp=true.skip=1000000.off=10.dur=inf.pub=inf => inf
    close.comp=true.skip=1000000.off=10.dur=inf.pub=2.5 => inf
    close.comp=true.skip=-2.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=-2.off=nil.dur=nil.pub=1 => 0
    close.comp=true.skip=-2.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=-2.off=nil.dur=nil.pub=100 => 0
    close.comp=true.skip=-2.off=nil.dur=nil.pub=-3 => 0
    close.comp=true.skip=-2.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=-2.off=nil.dur=nil.pub=inf => 0
    close.comp=true.skip=-2.off=nil.dur=nil.pub=2.5 => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=1 => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=100 => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=-3 => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=inf => 0
    close.comp=true.skip=-2.off=nil.dur=0.pub=2.5 => 0
    close.comp=true.skip=-2.off=nil.dur=10.pub=0 => 10
    close.comp=true.skip=-2.off=nil.dur=10.pub=1 => 10
    close.comp=true.skip=-2.off=nil.dur=10.pub=5 => 10
    close.comp=true.skip=-2.off=nil.dur=10.pub=100 => 10
    close.comp=true.skip=-2.off=nil.dur=10.pub=-3 => 10
    close.comp=true.skip=-2.off=nil.dur=10.pub=nan => 10
    close.comp=true.skip=-2.off=nil.dur=10.pub=inf => 10
    close.comp=true.skip=-2.off=nil.dur=10.pub=2.5 => 10
    close.comp=true.skip=-2.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=-2.off=nil.dur=60.pub=1 => 60
    close.comp=true.skip=-2.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=-2.off=nil.dur=60.pub=100 => 60
    close.comp=true.skip=-2.off=nil.dur=60.pub=-3 => 60
    close.comp=true.skip=-2.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=-2.off=nil.dur=60.pub=inf => 60
    close.comp=true.skip=-2.off=nil.dur=60.pub=2.5 => 60
    close.comp=true.skip=-2.off=nil.dur=-5.pub=0 => -5
    close.comp=true.skip=-2.off=nil.dur=-5.pub=1 => -5
    close.comp=true.skip=-2.off=nil.dur=-5.pub=5 => -5
    close.comp=true.skip=-2.off=nil.dur=-5.pub=100 => -5
    close.comp=true.skip=-2.off=nil.dur=-5.pub=-3 => -5
    close.comp=true.skip=-2.off=nil.dur=-5.pub=nan => -5
    close.comp=true.skip=-2.off=nil.dur=-5.pub=inf => -5
    close.comp=true.skip=-2.off=nil.dur=-5.pub=2.5 => -5
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=-2.off=nil.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=-2.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=-2.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=-2.off=nil.dur=nan.pub=1 => nan
    close.comp=true.skip=-2.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=-2.off=nil.dur=nan.pub=100 => nan
    close.comp=true.skip=-2.off=nil.dur=nan.pub=-3 => nan
    close.comp=true.skip=-2.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=-2.off=nil.dur=nan.pub=inf => nan
    close.comp=true.skip=-2.off=nil.dur=nan.pub=2.5 => nan
    close.comp=true.skip=-2.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=-2.off=nil.dur=inf.pub=1 => inf
    close.comp=true.skip=-2.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=-2.off=nil.dur=inf.pub=100 => inf
    close.comp=true.skip=-2.off=nil.dur=inf.pub=-3 => inf
    close.comp=true.skip=-2.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=-2.off=nil.dur=inf.pub=inf => inf
    close.comp=true.skip=-2.off=nil.dur=inf.pub=2.5 => inf
    close.comp=true.skip=-2.off=0.dur=nil.pub=0 => 0
    close.comp=true.skip=-2.off=0.dur=nil.pub=1 => 0
    close.comp=true.skip=-2.off=0.dur=nil.pub=5 => 0
    close.comp=true.skip=-2.off=0.dur=nil.pub=100 => 0
    close.comp=true.skip=-2.off=0.dur=nil.pub=-3 => 0
    close.comp=true.skip=-2.off=0.dur=nil.pub=nan => 0
    close.comp=true.skip=-2.off=0.dur=nil.pub=inf => 0
    close.comp=true.skip=-2.off=0.dur=nil.pub=2.5 => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=0 => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=1 => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=5 => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=100 => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=-3 => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=nan => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=inf => 0
    close.comp=true.skip=-2.off=0.dur=0.pub=2.5 => 0
    close.comp=true.skip=-2.off=0.dur=10.pub=0 => 10
    close.comp=true.skip=-2.off=0.dur=10.pub=1 => 10
    close.comp=true.skip=-2.off=0.dur=10.pub=5 => 10
    close.comp=true.skip=-2.off=0.dur=10.pub=100 => 10
    close.comp=true.skip=-2.off=0.dur=10.pub=-3 => 10
    close.comp=true.skip=-2.off=0.dur=10.pub=nan => 10
    close.comp=true.skip=-2.off=0.dur=10.pub=inf => 10
    close.comp=true.skip=-2.off=0.dur=10.pub=2.5 => 10
    close.comp=true.skip=-2.off=0.dur=60.pub=0 => 60
    close.comp=true.skip=-2.off=0.dur=60.pub=1 => 60
    close.comp=true.skip=-2.off=0.dur=60.pub=5 => 60
    close.comp=true.skip=-2.off=0.dur=60.pub=100 => 60
    close.comp=true.skip=-2.off=0.dur=60.pub=-3 => 60
    close.comp=true.skip=-2.off=0.dur=60.pub=nan => 60
    close.comp=true.skip=-2.off=0.dur=60.pub=inf => 60
    close.comp=true.skip=-2.off=0.dur=60.pub=2.5 => 60
    close.comp=true.skip=-2.off=0.dur=-5.pub=0 => -5
    close.comp=true.skip=-2.off=0.dur=-5.pub=1 => -5
    close.comp=true.skip=-2.off=0.dur=-5.pub=5 => -5
    close.comp=true.skip=-2.off=0.dur=-5.pub=100 => -5
    close.comp=true.skip=-2.off=0.dur=-5.pub=-3 => -5
    close.comp=true.skip=-2.off=0.dur=-5.pub=nan => -5
    close.comp=true.skip=-2.off=0.dur=-5.pub=inf => -5
    close.comp=true.skip=-2.off=0.dur=-5.pub=2.5 => -5
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=-2.off=0.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=-2.off=0.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=-2.off=0.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=-2.off=0.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=-2.off=0.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=-2.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=-2.off=0.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=-2.off=0.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=-2.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=-2.off=0.dur=nan.pub=0 => nan
    close.comp=true.skip=-2.off=0.dur=nan.pub=1 => nan
    close.comp=true.skip=-2.off=0.dur=nan.pub=5 => nan
    close.comp=true.skip=-2.off=0.dur=nan.pub=100 => nan
    close.comp=true.skip=-2.off=0.dur=nan.pub=-3 => nan
    close.comp=true.skip=-2.off=0.dur=nan.pub=nan => nan
    close.comp=true.skip=-2.off=0.dur=nan.pub=inf => nan
    close.comp=true.skip=-2.off=0.dur=nan.pub=2.5 => nan
    close.comp=true.skip=-2.off=0.dur=inf.pub=0 => inf
    close.comp=true.skip=-2.off=0.dur=inf.pub=1 => inf
    close.comp=true.skip=-2.off=0.dur=inf.pub=5 => inf
    close.comp=true.skip=-2.off=0.dur=inf.pub=100 => inf
    close.comp=true.skip=-2.off=0.dur=inf.pub=-3 => inf
    close.comp=true.skip=-2.off=0.dur=inf.pub=nan => inf
    close.comp=true.skip=-2.off=0.dur=inf.pub=inf => inf
    close.comp=true.skip=-2.off=0.dur=inf.pub=2.5 => inf
    close.comp=true.skip=-2.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=-2.off=4.dur=nil.pub=1 => 0
    close.comp=true.skip=-2.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=-2.off=4.dur=nil.pub=100 => 0
    close.comp=true.skip=-2.off=4.dur=nil.pub=-3 => 0
    close.comp=true.skip=-2.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=-2.off=4.dur=nil.pub=inf => 0
    close.comp=true.skip=-2.off=4.dur=nil.pub=2.5 => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=1 => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=100 => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=-3 => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=inf => 0
    close.comp=true.skip=-2.off=4.dur=0.pub=2.5 => 0
    close.comp=true.skip=-2.off=4.dur=10.pub=0 => 10
    close.comp=true.skip=-2.off=4.dur=10.pub=1 => 10
    close.comp=true.skip=-2.off=4.dur=10.pub=5 => 10
    close.comp=true.skip=-2.off=4.dur=10.pub=100 => 10
    close.comp=true.skip=-2.off=4.dur=10.pub=-3 => 10
    close.comp=true.skip=-2.off=4.dur=10.pub=nan => 10
    close.comp=true.skip=-2.off=4.dur=10.pub=inf => 10
    close.comp=true.skip=-2.off=4.dur=10.pub=2.5 => 10
    close.comp=true.skip=-2.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=-2.off=4.dur=60.pub=1 => 60
    close.comp=true.skip=-2.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=-2.off=4.dur=60.pub=100 => 60
    close.comp=true.skip=-2.off=4.dur=60.pub=-3 => 60
    close.comp=true.skip=-2.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=-2.off=4.dur=60.pub=inf => 60
    close.comp=true.skip=-2.off=4.dur=60.pub=2.5 => 60
    close.comp=true.skip=-2.off=4.dur=-5.pub=0 => -5
    close.comp=true.skip=-2.off=4.dur=-5.pub=1 => -5
    close.comp=true.skip=-2.off=4.dur=-5.pub=5 => -5
    close.comp=true.skip=-2.off=4.dur=-5.pub=100 => -5
    close.comp=true.skip=-2.off=4.dur=-5.pub=-3 => -5
    close.comp=true.skip=-2.off=4.dur=-5.pub=nan => -5
    close.comp=true.skip=-2.off=4.dur=-5.pub=inf => -5
    close.comp=true.skip=-2.off=4.dur=-5.pub=2.5 => -5
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=-2.off=4.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=-2.off=4.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=-2.off=4.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=-2.off=4.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=-2.off=4.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=-2.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=-2.off=4.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=-2.off=4.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=-2.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=-2.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=-2.off=4.dur=nan.pub=1 => nan
    close.comp=true.skip=-2.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=-2.off=4.dur=nan.pub=100 => nan
    close.comp=true.skip=-2.off=4.dur=nan.pub=-3 => nan
    close.comp=true.skip=-2.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=-2.off=4.dur=nan.pub=inf => nan
    close.comp=true.skip=-2.off=4.dur=nan.pub=2.5 => nan
    close.comp=true.skip=-2.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=-2.off=4.dur=inf.pub=1 => inf
    close.comp=true.skip=-2.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=-2.off=4.dur=inf.pub=100 => inf
    close.comp=true.skip=-2.off=4.dur=inf.pub=-3 => inf
    close.comp=true.skip=-2.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=-2.off=4.dur=inf.pub=inf => inf
    close.comp=true.skip=-2.off=4.dur=inf.pub=2.5 => inf
    close.comp=true.skip=-2.off=20.dur=nil.pub=0 => 0
    close.comp=true.skip=-2.off=20.dur=nil.pub=1 => 0
    close.comp=true.skip=-2.off=20.dur=nil.pub=5 => 0
    close.comp=true.skip=-2.off=20.dur=nil.pub=100 => 0
    close.comp=true.skip=-2.off=20.dur=nil.pub=-3 => 0
    close.comp=true.skip=-2.off=20.dur=nil.pub=nan => 0
    close.comp=true.skip=-2.off=20.dur=nil.pub=inf => 0
    close.comp=true.skip=-2.off=20.dur=nil.pub=2.5 => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=0 => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=1 => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=5 => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=100 => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=-3 => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=nan => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=inf => 0
    close.comp=true.skip=-2.off=20.dur=0.pub=2.5 => 0
    close.comp=true.skip=-2.off=20.dur=10.pub=0 => 10
    close.comp=true.skip=-2.off=20.dur=10.pub=1 => 10
    close.comp=true.skip=-2.off=20.dur=10.pub=5 => 10
    close.comp=true.skip=-2.off=20.dur=10.pub=100 => 10
    close.comp=true.skip=-2.off=20.dur=10.pub=-3 => 10
    close.comp=true.skip=-2.off=20.dur=10.pub=nan => 10
    close.comp=true.skip=-2.off=20.dur=10.pub=inf => 10
    close.comp=true.skip=-2.off=20.dur=10.pub=2.5 => 10
    close.comp=true.skip=-2.off=20.dur=60.pub=0 => 60
    close.comp=true.skip=-2.off=20.dur=60.pub=1 => 60
    close.comp=true.skip=-2.off=20.dur=60.pub=5 => 60
    close.comp=true.skip=-2.off=20.dur=60.pub=100 => 60
    close.comp=true.skip=-2.off=20.dur=60.pub=-3 => 60
    close.comp=true.skip=-2.off=20.dur=60.pub=nan => 60
    close.comp=true.skip=-2.off=20.dur=60.pub=inf => 60
    close.comp=true.skip=-2.off=20.dur=60.pub=2.5 => 60
    close.comp=true.skip=-2.off=20.dur=-5.pub=0 => -5
    close.comp=true.skip=-2.off=20.dur=-5.pub=1 => -5
    close.comp=true.skip=-2.off=20.dur=-5.pub=5 => -5
    close.comp=true.skip=-2.off=20.dur=-5.pub=100 => -5
    close.comp=true.skip=-2.off=20.dur=-5.pub=-3 => -5
    close.comp=true.skip=-2.off=20.dur=-5.pub=nan => -5
    close.comp=true.skip=-2.off=20.dur=-5.pub=inf => -5
    close.comp=true.skip=-2.off=20.dur=-5.pub=2.5 => -5
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=-2.off=20.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=-2.off=20.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=-2.off=20.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=-2.off=20.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=-2.off=20.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=-2.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=-2.off=20.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=-2.off=20.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=-2.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=-2.off=20.dur=nan.pub=0 => nan
    close.comp=true.skip=-2.off=20.dur=nan.pub=1 => nan
    close.comp=true.skip=-2.off=20.dur=nan.pub=5 => nan
    close.comp=true.skip=-2.off=20.dur=nan.pub=100 => nan
    close.comp=true.skip=-2.off=20.dur=nan.pub=-3 => nan
    close.comp=true.skip=-2.off=20.dur=nan.pub=nan => nan
    close.comp=true.skip=-2.off=20.dur=nan.pub=inf => nan
    close.comp=true.skip=-2.off=20.dur=nan.pub=2.5 => nan
    close.comp=true.skip=-2.off=20.dur=inf.pub=0 => inf
    close.comp=true.skip=-2.off=20.dur=inf.pub=1 => inf
    close.comp=true.skip=-2.off=20.dur=inf.pub=5 => inf
    close.comp=true.skip=-2.off=20.dur=inf.pub=100 => inf
    close.comp=true.skip=-2.off=20.dur=inf.pub=-3 => inf
    close.comp=true.skip=-2.off=20.dur=inf.pub=nan => inf
    close.comp=true.skip=-2.off=20.dur=inf.pub=inf => inf
    close.comp=true.skip=-2.off=20.dur=inf.pub=2.5 => inf
    close.comp=true.skip=-2.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=-2.off=-1.dur=nil.pub=1 => 0
    close.comp=true.skip=-2.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=-2.off=-1.dur=nil.pub=100 => 0
    close.comp=true.skip=-2.off=-1.dur=nil.pub=-3 => 0
    close.comp=true.skip=-2.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=-2.off=-1.dur=nil.pub=inf => 0
    close.comp=true.skip=-2.off=-1.dur=nil.pub=2.5 => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=1 => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=100 => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=-3 => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=inf => 0
    close.comp=true.skip=-2.off=-1.dur=0.pub=2.5 => 0
    close.comp=true.skip=-2.off=-1.dur=10.pub=0 => 10
    close.comp=true.skip=-2.off=-1.dur=10.pub=1 => 10
    close.comp=true.skip=-2.off=-1.dur=10.pub=5 => 10
    close.comp=true.skip=-2.off=-1.dur=10.pub=100 => 10
    close.comp=true.skip=-2.off=-1.dur=10.pub=-3 => 10
    close.comp=true.skip=-2.off=-1.dur=10.pub=nan => 10
    close.comp=true.skip=-2.off=-1.dur=10.pub=inf => 10
    close.comp=true.skip=-2.off=-1.dur=10.pub=2.5 => 10
    close.comp=true.skip=-2.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=-2.off=-1.dur=60.pub=1 => 60
    close.comp=true.skip=-2.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=-2.off=-1.dur=60.pub=100 => 60
    close.comp=true.skip=-2.off=-1.dur=60.pub=-3 => 60
    close.comp=true.skip=-2.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=-2.off=-1.dur=60.pub=inf => 60
    close.comp=true.skip=-2.off=-1.dur=60.pub=2.5 => 60
    close.comp=true.skip=-2.off=-1.dur=-5.pub=0 => -5
    close.comp=true.skip=-2.off=-1.dur=-5.pub=1 => -5
    close.comp=true.skip=-2.off=-1.dur=-5.pub=5 => -5
    close.comp=true.skip=-2.off=-1.dur=-5.pub=100 => -5
    close.comp=true.skip=-2.off=-1.dur=-5.pub=-3 => -5
    close.comp=true.skip=-2.off=-1.dur=-5.pub=nan => -5
    close.comp=true.skip=-2.off=-1.dur=-5.pub=inf => -5
    close.comp=true.skip=-2.off=-1.dur=-5.pub=2.5 => -5
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=-2.off=-1.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=-2.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=-2.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=-2.off=-1.dur=nan.pub=1 => nan
    close.comp=true.skip=-2.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=-2.off=-1.dur=nan.pub=100 => nan
    close.comp=true.skip=-2.off=-1.dur=nan.pub=-3 => nan
    close.comp=true.skip=-2.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=-2.off=-1.dur=nan.pub=inf => nan
    close.comp=true.skip=-2.off=-1.dur=nan.pub=2.5 => nan
    close.comp=true.skip=-2.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=-2.off=-1.dur=inf.pub=1 => inf
    close.comp=true.skip=-2.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=-2.off=-1.dur=inf.pub=100 => inf
    close.comp=true.skip=-2.off=-1.dur=inf.pub=-3 => inf
    close.comp=true.skip=-2.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=-2.off=-1.dur=inf.pub=inf => inf
    close.comp=true.skip=-2.off=-1.dur=inf.pub=2.5 => inf
    close.comp=true.skip=-2.off=10.dur=nil.pub=0 => 0
    close.comp=true.skip=-2.off=10.dur=nil.pub=1 => 0
    close.comp=true.skip=-2.off=10.dur=nil.pub=5 => 0
    close.comp=true.skip=-2.off=10.dur=nil.pub=100 => 0
    close.comp=true.skip=-2.off=10.dur=nil.pub=-3 => 0
    close.comp=true.skip=-2.off=10.dur=nil.pub=nan => 0
    close.comp=true.skip=-2.off=10.dur=nil.pub=inf => 0
    close.comp=true.skip=-2.off=10.dur=nil.pub=2.5 => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=0 => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=1 => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=5 => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=100 => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=-3 => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=nan => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=inf => 0
    close.comp=true.skip=-2.off=10.dur=0.pub=2.5 => 0
    close.comp=true.skip=-2.off=10.dur=10.pub=0 => 10
    close.comp=true.skip=-2.off=10.dur=10.pub=1 => 10
    close.comp=true.skip=-2.off=10.dur=10.pub=5 => 10
    close.comp=true.skip=-2.off=10.dur=10.pub=100 => 10
    close.comp=true.skip=-2.off=10.dur=10.pub=-3 => 10
    close.comp=true.skip=-2.off=10.dur=10.pub=nan => 10
    close.comp=true.skip=-2.off=10.dur=10.pub=inf => 10
    close.comp=true.skip=-2.off=10.dur=10.pub=2.5 => 10
    close.comp=true.skip=-2.off=10.dur=60.pub=0 => 60
    close.comp=true.skip=-2.off=10.dur=60.pub=1 => 60
    close.comp=true.skip=-2.off=10.dur=60.pub=5 => 60
    close.comp=true.skip=-2.off=10.dur=60.pub=100 => 60
    close.comp=true.skip=-2.off=10.dur=60.pub=-3 => 60
    close.comp=true.skip=-2.off=10.dur=60.pub=nan => 60
    close.comp=true.skip=-2.off=10.dur=60.pub=inf => 60
    close.comp=true.skip=-2.off=10.dur=60.pub=2.5 => 60
    close.comp=true.skip=-2.off=10.dur=-5.pub=0 => -5
    close.comp=true.skip=-2.off=10.dur=-5.pub=1 => -5
    close.comp=true.skip=-2.off=10.dur=-5.pub=5 => -5
    close.comp=true.skip=-2.off=10.dur=-5.pub=100 => -5
    close.comp=true.skip=-2.off=10.dur=-5.pub=-3 => -5
    close.comp=true.skip=-2.off=10.dur=-5.pub=nan => -5
    close.comp=true.skip=-2.off=10.dur=-5.pub=inf => -5
    close.comp=true.skip=-2.off=10.dur=-5.pub=2.5 => -5
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=-2.off=10.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=-2.off=10.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=-2.off=10.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=-2.off=10.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=-2.off=10.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=-2.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=-2.off=10.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=-2.off=10.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=-2.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=-2.off=10.dur=nan.pub=0 => nan
    close.comp=true.skip=-2.off=10.dur=nan.pub=1 => nan
    close.comp=true.skip=-2.off=10.dur=nan.pub=5 => nan
    close.comp=true.skip=-2.off=10.dur=nan.pub=100 => nan
    close.comp=true.skip=-2.off=10.dur=nan.pub=-3 => nan
    close.comp=true.skip=-2.off=10.dur=nan.pub=nan => nan
    close.comp=true.skip=-2.off=10.dur=nan.pub=inf => nan
    close.comp=true.skip=-2.off=10.dur=nan.pub=2.5 => nan
    close.comp=true.skip=-2.off=10.dur=inf.pub=0 => inf
    close.comp=true.skip=-2.off=10.dur=inf.pub=1 => inf
    close.comp=true.skip=-2.off=10.dur=inf.pub=5 => inf
    close.comp=true.skip=-2.off=10.dur=inf.pub=100 => inf
    close.comp=true.skip=-2.off=10.dur=inf.pub=-3 => inf
    close.comp=true.skip=-2.off=10.dur=inf.pub=nan => inf
    close.comp=true.skip=-2.off=10.dur=inf.pub=inf => inf
    close.comp=true.skip=-2.off=10.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nan.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=1 => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=100 => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=-3 => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=inf => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=1 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=100 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=-3 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=inf => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=2.5 => 0
    close.comp=true.skip=nan.off=nil.dur=10.pub=0 => 10
    close.comp=true.skip=nan.off=nil.dur=10.pub=1 => 10
    close.comp=true.skip=nan.off=nil.dur=10.pub=5 => 10
    close.comp=true.skip=nan.off=nil.dur=10.pub=100 => 10
    close.comp=true.skip=nan.off=nil.dur=10.pub=-3 => 10
    close.comp=true.skip=nan.off=nil.dur=10.pub=nan => 10
    close.comp=true.skip=nan.off=nil.dur=10.pub=inf => 10
    close.comp=true.skip=nan.off=nil.dur=10.pub=2.5 => 10
    close.comp=true.skip=nan.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=1 => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=100 => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=-3 => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=inf => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=2.5 => 60
    close.comp=true.skip=nan.off=nil.dur=-5.pub=0 => -5
    close.comp=true.skip=nan.off=nil.dur=-5.pub=1 => -5
    close.comp=true.skip=nan.off=nil.dur=-5.pub=5 => -5
    close.comp=true.skip=nan.off=nil.dur=-5.pub=100 => -5
    close.comp=true.skip=nan.off=nil.dur=-5.pub=-3 => -5
    close.comp=true.skip=nan.off=nil.dur=-5.pub=nan => -5
    close.comp=true.skip=nan.off=nil.dur=-5.pub=inf => -5
    close.comp=true.skip=nan.off=nil.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nan.off=nil.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nan.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nan.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=1 => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=100 => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=-3 => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=inf => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nan.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=1 => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=100 => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=-3 => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=inf => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nan.off=0.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=0.dur=nil.pub=1 => 0
    close.comp=true.skip=nan.off=0.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=0.dur=nil.pub=100 => 0
    close.comp=true.skip=nan.off=0.dur=nil.pub=-3 => 0
    close.comp=true.skip=nan.off=0.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=0.dur=nil.pub=inf => 0
    close.comp=true.skip=nan.off=0.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=1 => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=100 => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=-3 => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=inf => 0
    close.comp=true.skip=nan.off=0.dur=0.pub=2.5 => 0
    close.comp=true.skip=nan.off=0.dur=10.pub=0 => 10
    close.comp=true.skip=nan.off=0.dur=10.pub=1 => 10
    close.comp=true.skip=nan.off=0.dur=10.pub=5 => 10
    close.comp=true.skip=nan.off=0.dur=10.pub=100 => 10
    close.comp=true.skip=nan.off=0.dur=10.pub=-3 => 10
    close.comp=true.skip=nan.off=0.dur=10.pub=nan => 10
    close.comp=true.skip=nan.off=0.dur=10.pub=inf => 10
    close.comp=true.skip=nan.off=0.dur=10.pub=2.5 => 10
    close.comp=true.skip=nan.off=0.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=0.dur=60.pub=1 => 60
    close.comp=true.skip=nan.off=0.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=0.dur=60.pub=100 => 60
    close.comp=true.skip=nan.off=0.dur=60.pub=-3 => 60
    close.comp=true.skip=nan.off=0.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=0.dur=60.pub=inf => 60
    close.comp=true.skip=nan.off=0.dur=60.pub=2.5 => 60
    close.comp=true.skip=nan.off=0.dur=-5.pub=0 => -5
    close.comp=true.skip=nan.off=0.dur=-5.pub=1 => -5
    close.comp=true.skip=nan.off=0.dur=-5.pub=5 => -5
    close.comp=true.skip=nan.off=0.dur=-5.pub=100 => -5
    close.comp=true.skip=nan.off=0.dur=-5.pub=-3 => -5
    close.comp=true.skip=nan.off=0.dur=-5.pub=nan => -5
    close.comp=true.skip=nan.off=0.dur=-5.pub=inf => -5
    close.comp=true.skip=nan.off=0.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nan.off=0.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nan.off=0.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nan.off=0.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nan.off=0.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nan.off=0.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nan.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nan.off=0.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nan.off=0.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nan.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nan.off=0.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=0.dur=nan.pub=1 => nan
    close.comp=true.skip=nan.off=0.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=0.dur=nan.pub=100 => nan
    close.comp=true.skip=nan.off=0.dur=nan.pub=-3 => nan
    close.comp=true.skip=nan.off=0.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=0.dur=nan.pub=inf => nan
    close.comp=true.skip=nan.off=0.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nan.off=0.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=0.dur=inf.pub=1 => inf
    close.comp=true.skip=nan.off=0.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=0.dur=inf.pub=100 => inf
    close.comp=true.skip=nan.off=0.dur=inf.pub=-3 => inf
    close.comp=true.skip=nan.off=0.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=0.dur=inf.pub=inf => inf
    close.comp=true.skip=nan.off=0.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nan.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=1 => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=100 => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=-3 => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=inf => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=1 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=100 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=-3 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=inf => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=2.5 => 0
    close.comp=true.skip=nan.off=4.dur=10.pub=0 => 10
    close.comp=true.skip=nan.off=4.dur=10.pub=1 => 10
    close.comp=true.skip=nan.off=4.dur=10.pub=5 => 10
    close.comp=true.skip=nan.off=4.dur=10.pub=100 => 10
    close.comp=true.skip=nan.off=4.dur=10.pub=-3 => 10
    close.comp=true.skip=nan.off=4.dur=10.pub=nan => 10
    close.comp=true.skip=nan.off=4.dur=10.pub=inf => 10
    close.comp=true.skip=nan.off=4.dur=10.pub=2.5 => 10
    close.comp=true.skip=nan.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=1 => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=100 => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=-3 => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=inf => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=2.5 => 60
    close.comp=true.skip=nan.off=4.dur=-5.pub=0 => -5
    close.comp=true.skip=nan.off=4.dur=-5.pub=1 => -5
    close.comp=true.skip=nan.off=4.dur=-5.pub=5 => -5
    close.comp=true.skip=nan.off=4.dur=-5.pub=100 => -5
    close.comp=true.skip=nan.off=4.dur=-5.pub=-3 => -5
    close.comp=true.skip=nan.off=4.dur=-5.pub=nan => -5
    close.comp=true.skip=nan.off=4.dur=-5.pub=inf => -5
    close.comp=true.skip=nan.off=4.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nan.off=4.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nan.off=4.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nan.off=4.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nan.off=4.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nan.off=4.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nan.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nan.off=4.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nan.off=4.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nan.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nan.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=1 => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=100 => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=-3 => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=inf => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nan.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=1 => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=100 => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=-3 => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=inf => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nan.off=20.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=20.dur=nil.pub=1 => 0
    close.comp=true.skip=nan.off=20.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=20.dur=nil.pub=100 => 0
    close.comp=true.skip=nan.off=20.dur=nil.pub=-3 => 0
    close.comp=true.skip=nan.off=20.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=20.dur=nil.pub=inf => 0
    close.comp=true.skip=nan.off=20.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=1 => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=100 => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=-3 => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=inf => 0
    close.comp=true.skip=nan.off=20.dur=0.pub=2.5 => 0
    close.comp=true.skip=nan.off=20.dur=10.pub=0 => 10
    close.comp=true.skip=nan.off=20.dur=10.pub=1 => 10
    close.comp=true.skip=nan.off=20.dur=10.pub=5 => 10
    close.comp=true.skip=nan.off=20.dur=10.pub=100 => 10
    close.comp=true.skip=nan.off=20.dur=10.pub=-3 => 10
    close.comp=true.skip=nan.off=20.dur=10.pub=nan => 10
    close.comp=true.skip=nan.off=20.dur=10.pub=inf => 10
    close.comp=true.skip=nan.off=20.dur=10.pub=2.5 => 10
    close.comp=true.skip=nan.off=20.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=20.dur=60.pub=1 => 60
    close.comp=true.skip=nan.off=20.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=20.dur=60.pub=100 => 60
    close.comp=true.skip=nan.off=20.dur=60.pub=-3 => 60
    close.comp=true.skip=nan.off=20.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=20.dur=60.pub=inf => 60
    close.comp=true.skip=nan.off=20.dur=60.pub=2.5 => 60
    close.comp=true.skip=nan.off=20.dur=-5.pub=0 => -5
    close.comp=true.skip=nan.off=20.dur=-5.pub=1 => -5
    close.comp=true.skip=nan.off=20.dur=-5.pub=5 => -5
    close.comp=true.skip=nan.off=20.dur=-5.pub=100 => -5
    close.comp=true.skip=nan.off=20.dur=-5.pub=-3 => -5
    close.comp=true.skip=nan.off=20.dur=-5.pub=nan => -5
    close.comp=true.skip=nan.off=20.dur=-5.pub=inf => -5
    close.comp=true.skip=nan.off=20.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nan.off=20.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nan.off=20.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nan.off=20.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nan.off=20.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nan.off=20.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nan.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nan.off=20.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nan.off=20.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nan.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nan.off=20.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=20.dur=nan.pub=1 => nan
    close.comp=true.skip=nan.off=20.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=20.dur=nan.pub=100 => nan
    close.comp=true.skip=nan.off=20.dur=nan.pub=-3 => nan
    close.comp=true.skip=nan.off=20.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=20.dur=nan.pub=inf => nan
    close.comp=true.skip=nan.off=20.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nan.off=20.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=20.dur=inf.pub=1 => inf
    close.comp=true.skip=nan.off=20.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=20.dur=inf.pub=100 => inf
    close.comp=true.skip=nan.off=20.dur=inf.pub=-3 => inf
    close.comp=true.skip=nan.off=20.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=20.dur=inf.pub=inf => inf
    close.comp=true.skip=nan.off=20.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nan.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=1 => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=100 => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=-3 => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=inf => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=1 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=100 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=-3 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=inf => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=2.5 => 0
    close.comp=true.skip=nan.off=-1.dur=10.pub=0 => 10
    close.comp=true.skip=nan.off=-1.dur=10.pub=1 => 10
    close.comp=true.skip=nan.off=-1.dur=10.pub=5 => 10
    close.comp=true.skip=nan.off=-1.dur=10.pub=100 => 10
    close.comp=true.skip=nan.off=-1.dur=10.pub=-3 => 10
    close.comp=true.skip=nan.off=-1.dur=10.pub=nan => 10
    close.comp=true.skip=nan.off=-1.dur=10.pub=inf => 10
    close.comp=true.skip=nan.off=-1.dur=10.pub=2.5 => 10
    close.comp=true.skip=nan.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=1 => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=100 => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=-3 => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=inf => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=2.5 => 60
    close.comp=true.skip=nan.off=-1.dur=-5.pub=0 => -5
    close.comp=true.skip=nan.off=-1.dur=-5.pub=1 => -5
    close.comp=true.skip=nan.off=-1.dur=-5.pub=5 => -5
    close.comp=true.skip=nan.off=-1.dur=-5.pub=100 => -5
    close.comp=true.skip=nan.off=-1.dur=-5.pub=-3 => -5
    close.comp=true.skip=nan.off=-1.dur=-5.pub=nan => -5
    close.comp=true.skip=nan.off=-1.dur=-5.pub=inf => -5
    close.comp=true.skip=nan.off=-1.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nan.off=-1.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nan.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nan.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=1 => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=100 => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=-3 => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=inf => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nan.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=1 => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=100 => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=-3 => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=inf => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=2.5 => inf
    close.comp=true.skip=nan.off=10.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=10.dur=nil.pub=1 => 0
    close.comp=true.skip=nan.off=10.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=10.dur=nil.pub=100 => 0
    close.comp=true.skip=nan.off=10.dur=nil.pub=-3 => 0
    close.comp=true.skip=nan.off=10.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=10.dur=nil.pub=inf => 0
    close.comp=true.skip=nan.off=10.dur=nil.pub=2.5 => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=1 => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=100 => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=-3 => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=inf => 0
    close.comp=true.skip=nan.off=10.dur=0.pub=2.5 => 0
    close.comp=true.skip=nan.off=10.dur=10.pub=0 => 10
    close.comp=true.skip=nan.off=10.dur=10.pub=1 => 10
    close.comp=true.skip=nan.off=10.dur=10.pub=5 => 10
    close.comp=true.skip=nan.off=10.dur=10.pub=100 => 10
    close.comp=true.skip=nan.off=10.dur=10.pub=-3 => 10
    close.comp=true.skip=nan.off=10.dur=10.pub=nan => 10
    close.comp=true.skip=nan.off=10.dur=10.pub=inf => 10
    close.comp=true.skip=nan.off=10.dur=10.pub=2.5 => 10
    close.comp=true.skip=nan.off=10.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=10.dur=60.pub=1 => 60
    close.comp=true.skip=nan.off=10.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=10.dur=60.pub=100 => 60
    close.comp=true.skip=nan.off=10.dur=60.pub=-3 => 60
    close.comp=true.skip=nan.off=10.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=10.dur=60.pub=inf => 60
    close.comp=true.skip=nan.off=10.dur=60.pub=2.5 => 60
    close.comp=true.skip=nan.off=10.dur=-5.pub=0 => -5
    close.comp=true.skip=nan.off=10.dur=-5.pub=1 => -5
    close.comp=true.skip=nan.off=10.dur=-5.pub=5 => -5
    close.comp=true.skip=nan.off=10.dur=-5.pub=100 => -5
    close.comp=true.skip=nan.off=10.dur=-5.pub=-3 => -5
    close.comp=true.skip=nan.off=10.dur=-5.pub=nan => -5
    close.comp=true.skip=nan.off=10.dur=-5.pub=inf => -5
    close.comp=true.skip=nan.off=10.dur=-5.pub=2.5 => -5
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=nan.off=10.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=nan.off=10.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=nan.off=10.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=nan.off=10.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=nan.off=10.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=nan.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=nan.off=10.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=nan.off=10.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=nan.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=nan.off=10.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=10.dur=nan.pub=1 => nan
    close.comp=true.skip=nan.off=10.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=10.dur=nan.pub=100 => nan
    close.comp=true.skip=nan.off=10.dur=nan.pub=-3 => nan
    close.comp=true.skip=nan.off=10.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=10.dur=nan.pub=inf => nan
    close.comp=true.skip=nan.off=10.dur=nan.pub=2.5 => nan
    close.comp=true.skip=nan.off=10.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=10.dur=inf.pub=1 => inf
    close.comp=true.skip=nan.off=10.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=10.dur=inf.pub=100 => inf
    close.comp=true.skip=nan.off=10.dur=inf.pub=-3 => inf
    close.comp=true.skip=nan.off=10.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=10.dur=inf.pub=inf => inf
    close.comp=true.skip=nan.off=10.dur=inf.pub=2.5 => inf
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=1 => 0
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=100 => 0
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=-3 => 0
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=inf => 0
    close.comp=true.skip=2.5.off=nil.dur=nil.pub=2.5 => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=1 => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=100 => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=-3 => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=inf => 0
    close.comp=true.skip=2.5.off=nil.dur=0.pub=2.5 => 0
    close.comp=true.skip=2.5.off=nil.dur=10.pub=0 => 10
    close.comp=true.skip=2.5.off=nil.dur=10.pub=1 => 10
    close.comp=true.skip=2.5.off=nil.dur=10.pub=5 => 10
    close.comp=true.skip=2.5.off=nil.dur=10.pub=100 => 10
    close.comp=true.skip=2.5.off=nil.dur=10.pub=-3 => 10
    close.comp=true.skip=2.5.off=nil.dur=10.pub=nan => 10
    close.comp=true.skip=2.5.off=nil.dur=10.pub=inf => 10
    close.comp=true.skip=2.5.off=nil.dur=10.pub=2.5 => 10
    close.comp=true.skip=2.5.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=2.5.off=nil.dur=60.pub=1 => 60
    close.comp=true.skip=2.5.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=2.5.off=nil.dur=60.pub=100 => 60
    close.comp=true.skip=2.5.off=nil.dur=60.pub=-3 => 60
    close.comp=true.skip=2.5.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=2.5.off=nil.dur=60.pub=inf => 60
    close.comp=true.skip=2.5.off=nil.dur=60.pub=2.5 => 60
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=0 => -5
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=1 => -5
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=5 => -5
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=100 => -5
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=-3 => -5
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=nan => -5
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=inf => -5
    close.comp=true.skip=2.5.off=nil.dur=-5.pub=2.5 => -5
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=2.5.off=nil.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=1 => nan
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=100 => nan
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=-3 => nan
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=inf => nan
    close.comp=true.skip=2.5.off=nil.dur=nan.pub=2.5 => nan
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=1 => inf
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=100 => inf
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=-3 => inf
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=inf => inf
    close.comp=true.skip=2.5.off=nil.dur=inf.pub=2.5 => inf
    close.comp=true.skip=2.5.off=0.dur=nil.pub=0 => 0
    close.comp=true.skip=2.5.off=0.dur=nil.pub=1 => 0
    close.comp=true.skip=2.5.off=0.dur=nil.pub=5 => 0
    close.comp=true.skip=2.5.off=0.dur=nil.pub=100 => 0
    close.comp=true.skip=2.5.off=0.dur=nil.pub=-3 => 0
    close.comp=true.skip=2.5.off=0.dur=nil.pub=nan => 0
    close.comp=true.skip=2.5.off=0.dur=nil.pub=inf => 0
    close.comp=true.skip=2.5.off=0.dur=nil.pub=2.5 => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=0 => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=1 => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=5 => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=100 => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=-3 => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=nan => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=inf => 0
    close.comp=true.skip=2.5.off=0.dur=0.pub=2.5 => 0
    close.comp=true.skip=2.5.off=0.dur=10.pub=0 => 10
    close.comp=true.skip=2.5.off=0.dur=10.pub=1 => 10
    close.comp=true.skip=2.5.off=0.dur=10.pub=5 => 10
    close.comp=true.skip=2.5.off=0.dur=10.pub=100 => 10
    close.comp=true.skip=2.5.off=0.dur=10.pub=-3 => 10
    close.comp=true.skip=2.5.off=0.dur=10.pub=nan => 10
    close.comp=true.skip=2.5.off=0.dur=10.pub=inf => 10
    close.comp=true.skip=2.5.off=0.dur=10.pub=2.5 => 10
    close.comp=true.skip=2.5.off=0.dur=60.pub=0 => 60
    close.comp=true.skip=2.5.off=0.dur=60.pub=1 => 60
    close.comp=true.skip=2.5.off=0.dur=60.pub=5 => 60
    close.comp=true.skip=2.5.off=0.dur=60.pub=100 => 60
    close.comp=true.skip=2.5.off=0.dur=60.pub=-3 => 60
    close.comp=true.skip=2.5.off=0.dur=60.pub=nan => 60
    close.comp=true.skip=2.5.off=0.dur=60.pub=inf => 60
    close.comp=true.skip=2.5.off=0.dur=60.pub=2.5 => 60
    close.comp=true.skip=2.5.off=0.dur=-5.pub=0 => -5
    close.comp=true.skip=2.5.off=0.dur=-5.pub=1 => -5
    close.comp=true.skip=2.5.off=0.dur=-5.pub=5 => -5
    close.comp=true.skip=2.5.off=0.dur=-5.pub=100 => -5
    close.comp=true.skip=2.5.off=0.dur=-5.pub=-3 => -5
    close.comp=true.skip=2.5.off=0.dur=-5.pub=nan => -5
    close.comp=true.skip=2.5.off=0.dur=-5.pub=inf => -5
    close.comp=true.skip=2.5.off=0.dur=-5.pub=2.5 => -5
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=2.5.off=0.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=2.5.off=0.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=2.5.off=0.dur=nan.pub=0 => nan
    close.comp=true.skip=2.5.off=0.dur=nan.pub=1 => nan
    close.comp=true.skip=2.5.off=0.dur=nan.pub=5 => nan
    close.comp=true.skip=2.5.off=0.dur=nan.pub=100 => nan
    close.comp=true.skip=2.5.off=0.dur=nan.pub=-3 => nan
    close.comp=true.skip=2.5.off=0.dur=nan.pub=nan => nan
    close.comp=true.skip=2.5.off=0.dur=nan.pub=inf => nan
    close.comp=true.skip=2.5.off=0.dur=nan.pub=2.5 => nan
    close.comp=true.skip=2.5.off=0.dur=inf.pub=0 => inf
    close.comp=true.skip=2.5.off=0.dur=inf.pub=1 => inf
    close.comp=true.skip=2.5.off=0.dur=inf.pub=5 => inf
    close.comp=true.skip=2.5.off=0.dur=inf.pub=100 => inf
    close.comp=true.skip=2.5.off=0.dur=inf.pub=-3 => inf
    close.comp=true.skip=2.5.off=0.dur=inf.pub=nan => inf
    close.comp=true.skip=2.5.off=0.dur=inf.pub=inf => inf
    close.comp=true.skip=2.5.off=0.dur=inf.pub=2.5 => inf
    close.comp=true.skip=2.5.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=2.5.off=4.dur=nil.pub=1 => 0
    close.comp=true.skip=2.5.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=2.5.off=4.dur=nil.pub=100 => 0
    close.comp=true.skip=2.5.off=4.dur=nil.pub=-3 => 0
    close.comp=true.skip=2.5.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=2.5.off=4.dur=nil.pub=inf => 0
    close.comp=true.skip=2.5.off=4.dur=nil.pub=2.5 => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=1 => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=100 => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=-3 => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=inf => 0
    close.comp=true.skip=2.5.off=4.dur=0.pub=2.5 => 0
    close.comp=true.skip=2.5.off=4.dur=10.pub=0 => 10
    close.comp=true.skip=2.5.off=4.dur=10.pub=1 => 10
    close.comp=true.skip=2.5.off=4.dur=10.pub=5 => 10
    close.comp=true.skip=2.5.off=4.dur=10.pub=100 => 10
    close.comp=true.skip=2.5.off=4.dur=10.pub=-3 => 10
    close.comp=true.skip=2.5.off=4.dur=10.pub=nan => 10
    close.comp=true.skip=2.5.off=4.dur=10.pub=inf => 10
    close.comp=true.skip=2.5.off=4.dur=10.pub=2.5 => 10
    close.comp=true.skip=2.5.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=2.5.off=4.dur=60.pub=1 => 60
    close.comp=true.skip=2.5.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=2.5.off=4.dur=60.pub=100 => 60
    close.comp=true.skip=2.5.off=4.dur=60.pub=-3 => 60
    close.comp=true.skip=2.5.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=2.5.off=4.dur=60.pub=inf => 60
    close.comp=true.skip=2.5.off=4.dur=60.pub=2.5 => 60
    close.comp=true.skip=2.5.off=4.dur=-5.pub=0 => -5
    close.comp=true.skip=2.5.off=4.dur=-5.pub=1 => -5
    close.comp=true.skip=2.5.off=4.dur=-5.pub=5 => -5
    close.comp=true.skip=2.5.off=4.dur=-5.pub=100 => -5
    close.comp=true.skip=2.5.off=4.dur=-5.pub=-3 => -5
    close.comp=true.skip=2.5.off=4.dur=-5.pub=nan => -5
    close.comp=true.skip=2.5.off=4.dur=-5.pub=inf => -5
    close.comp=true.skip=2.5.off=4.dur=-5.pub=2.5 => -5
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=2.5.off=4.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=2.5.off=4.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=2.5.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=2.5.off=4.dur=nan.pub=1 => nan
    close.comp=true.skip=2.5.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=2.5.off=4.dur=nan.pub=100 => nan
    close.comp=true.skip=2.5.off=4.dur=nan.pub=-3 => nan
    close.comp=true.skip=2.5.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=2.5.off=4.dur=nan.pub=inf => nan
    close.comp=true.skip=2.5.off=4.dur=nan.pub=2.5 => nan
    close.comp=true.skip=2.5.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=2.5.off=4.dur=inf.pub=1 => inf
    close.comp=true.skip=2.5.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=2.5.off=4.dur=inf.pub=100 => inf
    close.comp=true.skip=2.5.off=4.dur=inf.pub=-3 => inf
    close.comp=true.skip=2.5.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=2.5.off=4.dur=inf.pub=inf => inf
    close.comp=true.skip=2.5.off=4.dur=inf.pub=2.5 => inf
    close.comp=true.skip=2.5.off=20.dur=nil.pub=0 => 0
    close.comp=true.skip=2.5.off=20.dur=nil.pub=1 => 0
    close.comp=true.skip=2.5.off=20.dur=nil.pub=5 => 0
    close.comp=true.skip=2.5.off=20.dur=nil.pub=100 => 0
    close.comp=true.skip=2.5.off=20.dur=nil.pub=-3 => 0
    close.comp=true.skip=2.5.off=20.dur=nil.pub=nan => 0
    close.comp=true.skip=2.5.off=20.dur=nil.pub=inf => 0
    close.comp=true.skip=2.5.off=20.dur=nil.pub=2.5 => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=0 => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=1 => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=5 => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=100 => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=-3 => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=nan => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=inf => 0
    close.comp=true.skip=2.5.off=20.dur=0.pub=2.5 => 0
    close.comp=true.skip=2.5.off=20.dur=10.pub=0 => 10
    close.comp=true.skip=2.5.off=20.dur=10.pub=1 => 10
    close.comp=true.skip=2.5.off=20.dur=10.pub=5 => 10
    close.comp=true.skip=2.5.off=20.dur=10.pub=100 => 10
    close.comp=true.skip=2.5.off=20.dur=10.pub=-3 => 10
    close.comp=true.skip=2.5.off=20.dur=10.pub=nan => 10
    close.comp=true.skip=2.5.off=20.dur=10.pub=inf => 10
    close.comp=true.skip=2.5.off=20.dur=10.pub=2.5 => 10
    close.comp=true.skip=2.5.off=20.dur=60.pub=0 => 60
    close.comp=true.skip=2.5.off=20.dur=60.pub=1 => 60
    close.comp=true.skip=2.5.off=20.dur=60.pub=5 => 60
    close.comp=true.skip=2.5.off=20.dur=60.pub=100 => 60
    close.comp=true.skip=2.5.off=20.dur=60.pub=-3 => 60
    close.comp=true.skip=2.5.off=20.dur=60.pub=nan => 60
    close.comp=true.skip=2.5.off=20.dur=60.pub=inf => 60
    close.comp=true.skip=2.5.off=20.dur=60.pub=2.5 => 60
    close.comp=true.skip=2.5.off=20.dur=-5.pub=0 => -5
    close.comp=true.skip=2.5.off=20.dur=-5.pub=1 => -5
    close.comp=true.skip=2.5.off=20.dur=-5.pub=5 => -5
    close.comp=true.skip=2.5.off=20.dur=-5.pub=100 => -5
    close.comp=true.skip=2.5.off=20.dur=-5.pub=-3 => -5
    close.comp=true.skip=2.5.off=20.dur=-5.pub=nan => -5
    close.comp=true.skip=2.5.off=20.dur=-5.pub=inf => -5
    close.comp=true.skip=2.5.off=20.dur=-5.pub=2.5 => -5
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=2.5.off=20.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=2.5.off=20.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=2.5.off=20.dur=nan.pub=0 => nan
    close.comp=true.skip=2.5.off=20.dur=nan.pub=1 => nan
    close.comp=true.skip=2.5.off=20.dur=nan.pub=5 => nan
    close.comp=true.skip=2.5.off=20.dur=nan.pub=100 => nan
    close.comp=true.skip=2.5.off=20.dur=nan.pub=-3 => nan
    close.comp=true.skip=2.5.off=20.dur=nan.pub=nan => nan
    close.comp=true.skip=2.5.off=20.dur=nan.pub=inf => nan
    close.comp=true.skip=2.5.off=20.dur=nan.pub=2.5 => nan
    close.comp=true.skip=2.5.off=20.dur=inf.pub=0 => inf
    close.comp=true.skip=2.5.off=20.dur=inf.pub=1 => inf
    close.comp=true.skip=2.5.off=20.dur=inf.pub=5 => inf
    close.comp=true.skip=2.5.off=20.dur=inf.pub=100 => inf
    close.comp=true.skip=2.5.off=20.dur=inf.pub=-3 => inf
    close.comp=true.skip=2.5.off=20.dur=inf.pub=nan => inf
    close.comp=true.skip=2.5.off=20.dur=inf.pub=inf => inf
    close.comp=true.skip=2.5.off=20.dur=inf.pub=2.5 => inf
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=1 => 0
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=100 => 0
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=-3 => 0
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=inf => 0
    close.comp=true.skip=2.5.off=-1.dur=nil.pub=2.5 => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=1 => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=100 => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=-3 => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=inf => 0
    close.comp=true.skip=2.5.off=-1.dur=0.pub=2.5 => 0
    close.comp=true.skip=2.5.off=-1.dur=10.pub=0 => 10
    close.comp=true.skip=2.5.off=-1.dur=10.pub=1 => 10
    close.comp=true.skip=2.5.off=-1.dur=10.pub=5 => 10
    close.comp=true.skip=2.5.off=-1.dur=10.pub=100 => 10
    close.comp=true.skip=2.5.off=-1.dur=10.pub=-3 => 10
    close.comp=true.skip=2.5.off=-1.dur=10.pub=nan => 10
    close.comp=true.skip=2.5.off=-1.dur=10.pub=inf => 10
    close.comp=true.skip=2.5.off=-1.dur=10.pub=2.5 => 10
    close.comp=true.skip=2.5.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=2.5.off=-1.dur=60.pub=1 => 60
    close.comp=true.skip=2.5.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=2.5.off=-1.dur=60.pub=100 => 60
    close.comp=true.skip=2.5.off=-1.dur=60.pub=-3 => 60
    close.comp=true.skip=2.5.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=2.5.off=-1.dur=60.pub=inf => 60
    close.comp=true.skip=2.5.off=-1.dur=60.pub=2.5 => 60
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=0 => -5
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=1 => -5
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=5 => -5
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=100 => -5
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=-3 => -5
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=nan => -5
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=inf => -5
    close.comp=true.skip=2.5.off=-1.dur=-5.pub=2.5 => -5
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=2.5.off=-1.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=1 => nan
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=100 => nan
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=-3 => nan
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=inf => nan
    close.comp=true.skip=2.5.off=-1.dur=nan.pub=2.5 => nan
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=1 => inf
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=100 => inf
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=-3 => inf
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=inf => inf
    close.comp=true.skip=2.5.off=-1.dur=inf.pub=2.5 => inf
    close.comp=true.skip=2.5.off=10.dur=nil.pub=0 => 0
    close.comp=true.skip=2.5.off=10.dur=nil.pub=1 => 0
    close.comp=true.skip=2.5.off=10.dur=nil.pub=5 => 0
    close.comp=true.skip=2.5.off=10.dur=nil.pub=100 => 0
    close.comp=true.skip=2.5.off=10.dur=nil.pub=-3 => 0
    close.comp=true.skip=2.5.off=10.dur=nil.pub=nan => 0
    close.comp=true.skip=2.5.off=10.dur=nil.pub=inf => 0
    close.comp=true.skip=2.5.off=10.dur=nil.pub=2.5 => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=0 => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=1 => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=5 => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=100 => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=-3 => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=nan => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=inf => 0
    close.comp=true.skip=2.5.off=10.dur=0.pub=2.5 => 0
    close.comp=true.skip=2.5.off=10.dur=10.pub=0 => 10
    close.comp=true.skip=2.5.off=10.dur=10.pub=1 => 10
    close.comp=true.skip=2.5.off=10.dur=10.pub=5 => 10
    close.comp=true.skip=2.5.off=10.dur=10.pub=100 => 10
    close.comp=true.skip=2.5.off=10.dur=10.pub=-3 => 10
    close.comp=true.skip=2.5.off=10.dur=10.pub=nan => 10
    close.comp=true.skip=2.5.off=10.dur=10.pub=inf => 10
    close.comp=true.skip=2.5.off=10.dur=10.pub=2.5 => 10
    close.comp=true.skip=2.5.off=10.dur=60.pub=0 => 60
    close.comp=true.skip=2.5.off=10.dur=60.pub=1 => 60
    close.comp=true.skip=2.5.off=10.dur=60.pub=5 => 60
    close.comp=true.skip=2.5.off=10.dur=60.pub=100 => 60
    close.comp=true.skip=2.5.off=10.dur=60.pub=-3 => 60
    close.comp=true.skip=2.5.off=10.dur=60.pub=nan => 60
    close.comp=true.skip=2.5.off=10.dur=60.pub=inf => 60
    close.comp=true.skip=2.5.off=10.dur=60.pub=2.5 => 60
    close.comp=true.skip=2.5.off=10.dur=-5.pub=0 => -5
    close.comp=true.skip=2.5.off=10.dur=-5.pub=1 => -5
    close.comp=true.skip=2.5.off=10.dur=-5.pub=5 => -5
    close.comp=true.skip=2.5.off=10.dur=-5.pub=100 => -5
    close.comp=true.skip=2.5.off=10.dur=-5.pub=-3 => -5
    close.comp=true.skip=2.5.off=10.dur=-5.pub=nan => -5
    close.comp=true.skip=2.5.off=10.dur=-5.pub=inf => -5
    close.comp=true.skip=2.5.off=10.dur=-5.pub=2.5 => -5
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=0 => 1000000000
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=1 => 1000000000
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=5 => 1000000000
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=100 => 1000000000
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=-3 => 1000000000
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=nan => 1000000000
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=inf => 1000000000
    close.comp=true.skip=2.5.off=10.dur=1000000000.pub=2.5 => 1000000000
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=0 => 2.5
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=1 => 2.5
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=5 => 2.5
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=100 => 2.5
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=-3 => 2.5
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=nan => 2.5
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=inf => 2.5
    close.comp=true.skip=2.5.off=10.dur=2.5.pub=2.5 => 2.5
    close.comp=true.skip=2.5.off=10.dur=nan.pub=0 => nan
    close.comp=true.skip=2.5.off=10.dur=nan.pub=1 => nan
    close.comp=true.skip=2.5.off=10.dur=nan.pub=5 => nan
    close.comp=true.skip=2.5.off=10.dur=nan.pub=100 => nan
    close.comp=true.skip=2.5.off=10.dur=nan.pub=-3 => nan
    close.comp=true.skip=2.5.off=10.dur=nan.pub=nan => nan
    close.comp=true.skip=2.5.off=10.dur=nan.pub=inf => nan
    close.comp=true.skip=2.5.off=10.dur=nan.pub=2.5 => nan
    close.comp=true.skip=2.5.off=10.dur=inf.pub=0 => inf
    close.comp=true.skip=2.5.off=10.dur=inf.pub=1 => inf
    close.comp=true.skip=2.5.off=10.dur=inf.pub=5 => inf
    close.comp=true.skip=2.5.off=10.dur=inf.pub=100 => inf
    close.comp=true.skip=2.5.off=10.dur=inf.pub=-3 => inf
    close.comp=true.skip=2.5.off=10.dur=inf.pub=nan => inf
    close.comp=true.skip=2.5.off=10.dur=inf.pub=inf => inf
    close.comp=true.skip=2.5.off=10.dur=inf.pub=2.5 => inf
    reward.r=false.ev=nil.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=firstquartile.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=firstquartile.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=firstquartile.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=midpoint.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=midpoint.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=midpoint.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=thirdquartile.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=thirdquartile.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=unknown.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=unknown.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=unknown.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=creativeView.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=creativeView.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=creativeView.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=nil.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=nil.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=nil.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=nil.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=nil.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=-1.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=-1.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=-1.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=-1.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=-1.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=0.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=0.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=0.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=0.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=0.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=0.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=0.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=0.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=0.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=0.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=0.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=100.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=100.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=100.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=100.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=100.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=100.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=100.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=100.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=100.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=100.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=100.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=1000.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=1000.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=1000.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=1000.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=1000.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=1000.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=1000.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=1000.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=1000.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=1000.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=1000.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=nil.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=nil.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=2.5.dur=0.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=0.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=0.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=0.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=2.5.dur=0.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=2.5.dur=10.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=10.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=10.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=10.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=2.5.dur=10.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=-5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=-5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=Complete.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=40.5.post=-1 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=Complete.vt=2.5.dur=40.5.post=5 => reward=-1 post=5
    reward.r=false.ev=Complete.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=true.ev=nil.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=nil.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=nil.vt=nil.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=nil.vt=nil.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=nil.vt=nil.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=nil.vt=nil.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=nil.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=nil.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=nil.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=nil.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=nil.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=nil.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=-1.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=nil.vt=-1.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=nil.vt=-1.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=nil.vt=-1.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=nil.vt=-1.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=nil.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=-1.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=nil.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=-1.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=nil.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=nil.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=0.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=0.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=0.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=0.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=nil.vt=0.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=0.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=nil.vt=0.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=0.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=0.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=0.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=5.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=nil.vt=5.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=nil.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=nil.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=nil.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=5.dur=40.5.post=nil => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=40.5.post=-1 => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=40.5.post=0 => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=40.5.post=5 => reward=5 post=10
    reward.r=true.ev=nil.vt=5.dur=40.5.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=nil.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=100.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=nil.vt=100.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=nil.vt=100.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=nil.vt=100.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=nil.vt=100.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=nil.vt=100.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=100.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=nil.vt=100.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=100.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=nil.vt=100.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=100.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=100.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=100.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=100.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=nil.vt=100.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=nil.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=1000.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=nil.vt=1000.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=nil.vt=1000.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=nil.vt=1000.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=nil.vt=1000.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=nil.vt=1000.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=1000.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=nil.vt=1000.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=1000.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=nil.vt=1000.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=1000.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=1000.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=1000.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=1000.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=nil.vt=1000.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=nil.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=nil.vt=2.5.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=start.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=nil.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=nil.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=nil.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=-5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=-5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=nil.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=nil.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=nil.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=-1.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=-5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=-5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=-1.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=-1.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=0.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=0.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=0.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=-5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=-5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=0.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=0.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=0.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=0.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=5.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=-5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=-5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=5.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=5.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=100.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=100.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=100.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=-5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=-5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=100.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=100.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=100.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=100.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=1000.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=1000.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=1000.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=-5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=-5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=1000.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=1000.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=1000.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=1000.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=10.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=10.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=10.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=10.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=2.5.dur=10.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=-5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=-5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=2.5.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=-1 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=5 => reward=0 post=5
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=nil.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=nil.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=nil.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=nil.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=firstquartile.vt=nil.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=firstquartile.vt=nil.dur=-5.post=nil => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=-5.post=-1 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=-5.post=0 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=nil.dur=-5.post=5 => reward=-1.25 post=5
    reward.r=true.ev=firstquartile.vt=nil.dur=-5.post=2.5 => reward=-1.25 post=2.5
    reward.r=true.ev=firstquartile.vt=nil.dur=40.5.post=nil => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=nil.dur=40.5.post=-1 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=nil.dur=40.5.post=0 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=nil.dur=40.5.post=5 => reward=10.125 post=15.125
    reward.r=true.ev=firstquartile.vt=nil.dur=40.5.post=2.5 => reward=10.125 post=12.625
    reward.r=true.ev=firstquartile.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=-1.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=-1.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=-1.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=-1.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=firstquartile.vt=-1.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=firstquartile.vt=-1.dur=-5.post=nil => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=-5.post=-1 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=-5.post=0 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=-1.dur=-5.post=5 => reward=-1.25 post=5
    reward.r=true.ev=firstquartile.vt=-1.dur=-5.post=2.5 => reward=-1.25 post=2.5
    reward.r=true.ev=firstquartile.vt=-1.dur=40.5.post=nil => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=-1.dur=40.5.post=-1 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=-1.dur=40.5.post=0 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=-1.dur=40.5.post=5 => reward=10.125 post=15.125
    reward.r=true.ev=firstquartile.vt=-1.dur=40.5.post=2.5 => reward=10.125 post=12.625
    reward.r=true.ev=firstquartile.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=0.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=0.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=0.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=0.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=firstquartile.vt=0.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=firstquartile.vt=0.dur=-5.post=nil => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=-5.post=-1 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=-5.post=0 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=0.dur=-5.post=5 => reward=-1.25 post=5
    reward.r=true.ev=firstquartile.vt=0.dur=-5.post=2.5 => reward=-1.25 post=2.5
    reward.r=true.ev=firstquartile.vt=0.dur=40.5.post=nil => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=0.dur=40.5.post=-1 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=0.dur=40.5.post=0 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=0.dur=40.5.post=5 => reward=10.125 post=15.125
    reward.r=true.ev=firstquartile.vt=0.dur=40.5.post=2.5 => reward=10.125 post=12.625
    reward.r=true.ev=firstquartile.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=5.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=5.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=5.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=5.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=firstquartile.vt=5.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=firstquartile.vt=5.dur=-5.post=nil => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=-5.post=-1 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=-5.post=0 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=5.dur=-5.post=5 => reward=-1.25 post=5
    reward.r=true.ev=firstquartile.vt=5.dur=-5.post=2.5 => reward=-1.25 post=2.5
    reward.r=true.ev=firstquartile.vt=5.dur=40.5.post=nil => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=5.dur=40.5.post=-1 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=5.dur=40.5.post=0 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=5.dur=40.5.post=5 => reward=10.125 post=15.125
    reward.r=true.ev=firstquartile.vt=5.dur=40.5.post=2.5 => reward=10.125 post=12.625
    reward.r=true.ev=firstquartile.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=100.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=100.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=100.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=100.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=firstquartile.vt=100.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=firstquartile.vt=100.dur=-5.post=nil => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=-5.post=-1 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=-5.post=0 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=100.dur=-5.post=5 => reward=-1.25 post=5
    reward.r=true.ev=firstquartile.vt=100.dur=-5.post=2.5 => reward=-1.25 post=2.5
    reward.r=true.ev=firstquartile.vt=100.dur=40.5.post=nil => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=100.dur=40.5.post=-1 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=100.dur=40.5.post=0 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=100.dur=40.5.post=5 => reward=10.125 post=15.125
    reward.r=true.ev=firstquartile.vt=100.dur=40.5.post=2.5 => reward=10.125 post=12.625
    reward.r=true.ev=firstquartile.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=1000.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=1000.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=1000.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=1000.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=firstquartile.vt=1000.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=firstquartile.vt=1000.dur=-5.post=nil => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=-5.post=-1 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=-5.post=0 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=1000.dur=-5.post=5 => reward=-1.25 post=5
    reward.r=true.ev=firstquartile.vt=1000.dur=-5.post=2.5 => reward=-1.25 post=2.5
    reward.r=true.ev=firstquartile.vt=1000.dur=40.5.post=nil => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=1000.dur=40.5.post=-1 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=1000.dur=40.5.post=0 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=1000.dur=40.5.post=5 => reward=10.125 post=15.125
    reward.r=true.ev=firstquartile.vt=1000.dur=40.5.post=2.5 => reward=10.125 post=12.625
    reward.r=true.ev=firstquartile.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=firstquartile.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=firstquartile.vt=2.5.dur=10.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=2.5.dur=10.post=-1 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=2.5.dur=10.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=firstquartile.vt=2.5.dur=10.post=5 => reward=2.5 post=7.5
    reward.r=true.ev=firstquartile.vt=2.5.dur=10.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=firstquartile.vt=2.5.dur=-5.post=nil => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=-5.post=-1 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=-5.post=0 => reward=-1.25 post=0
    reward.r=true.ev=firstquartile.vt=2.5.dur=-5.post=5 => reward=-1.25 post=5
    reward.r=true.ev=firstquartile.vt=2.5.dur=-5.post=2.5 => reward=-1.25 post=2.5
    reward.r=true.ev=firstquartile.vt=2.5.dur=40.5.post=nil => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=2.5.dur=40.5.post=-1 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=2.5.dur=40.5.post=0 => reward=10.125 post=10.125
    reward.r=true.ev=firstquartile.vt=2.5.dur=40.5.post=5 => reward=10.125 post=15.125
    reward.r=true.ev=firstquartile.vt=2.5.dur=40.5.post=2.5 => reward=10.125 post=12.625
    reward.r=true.ev=midpoint.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=nil.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=midpoint.vt=nil.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=nil.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=nil.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=midpoint.vt=nil.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=midpoint.vt=nil.dur=-5.post=nil => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=-5.post=-1 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=-5.post=0 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=nil.dur=-5.post=5 => reward=-2.5 post=5
    reward.r=true.ev=midpoint.vt=nil.dur=-5.post=2.5 => reward=-2.5 post=2.5
    reward.r=true.ev=midpoint.vt=nil.dur=40.5.post=nil => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=nil.dur=40.5.post=-1 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=nil.dur=40.5.post=0 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=nil.dur=40.5.post=5 => reward=20.25 post=25.25
    reward.r=true.ev=midpoint.vt=nil.dur=40.5.post=2.5 => reward=20.25 post=22.75
    reward.r=true.ev=midpoint.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=-1.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=midpoint.vt=-1.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=-1.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=-1.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=midpoint.vt=-1.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=midpoint.vt=-1.dur=-5.post=nil => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=-5.post=-1 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=-5.post=0 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=-1.dur=-5.post=5 => reward=-2.5 post=5
    reward.r=true.ev=midpoint.vt=-1.dur=-5.post=2.5 => reward=-2.5 post=2.5
    reward.r=true.ev=midpoint.vt=-1.dur=40.5.post=nil => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=-1.dur=40.5.post=-1 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=-1.dur=40.5.post=0 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=-1.dur=40.5.post=5 => reward=20.25 post=25.25
    reward.r=true.ev=midpoint.vt=-1.dur=40.5.post=2.5 => reward=20.25 post=22.75
    reward.r=true.ev=midpoint.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=0.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=midpoint.vt=0.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=0.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=0.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=midpoint.vt=0.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=midpoint.vt=0.dur=-5.post=nil => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=0.dur=-5.post=-1 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=0.dur=-5.post=0 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=0.dur=-5.post=5 => reward=-2.5 post=5
    reward.r=true.ev=midpoint.vt=0.dur=-5.post=2.5 => reward=-2.5 post=2.5
    reward.r=true.ev=midpoint.vt=0.dur=40.5.post=nil => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=0.dur=40.5.post=-1 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=0.dur=40.5.post=0 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=0.dur=40.5.post=5 => reward=20.25 post=25.25
    reward.r=true.ev=midpoint.vt=0.dur=40.5.post=2.5 => reward=20.25 post=22.75
    reward.r=true.ev=midpoint.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=5.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=midpoint.vt=5.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=5.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=5.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=midpoint.vt=5.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=midpoint.vt=5.dur=-5.post=nil => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=5.dur=-5.post=-1 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=5.dur=-5.post=0 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=5.dur=-5.post=5 => reward=-2.5 post=5
    reward.r=true.ev=midpoint.vt=5.dur=-5.post=2.5 => reward=-2.5 post=2.5
    reward.r=true.ev=midpoint.vt=5.dur=40.5.post=nil => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=5.dur=40.5.post=-1 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=5.dur=40.5.post=0 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=5.dur=40.5.post=5 => reward=20.25 post=25.25
    reward.r=true.ev=midpoint.vt=5.dur=40.5.post=2.5 => reward=20.25 post=22.75
    reward.r=true.ev=midpoint.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=100.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=midpoint.vt=100.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=100.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=100.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=midpoint.vt=100.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=midpoint.vt=100.dur=-5.post=nil => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=100.dur=-5.post=-1 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=100.dur=-5.post=0 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=100.dur=-5.post=5 => reward=-2.5 post=5
    reward.r=true.ev=midpoint.vt=100.dur=-5.post=2.5 => reward=-2.5 post=2.5
    reward.r=true.ev=midpoint.vt=100.dur=40.5.post=nil => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=100.dur=40.5.post=-1 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=100.dur=40.5.post=0 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=100.dur=40.5.post=5 => reward=20.25 post=25.25
    reward.r=true.ev=midpoint.vt=100.dur=40.5.post=2.5 => reward=20.25 post=22.75
    reward.r=true.ev=midpoint.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=1000.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=midpoint.vt=1000.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=1000.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=1000.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=midpoint.vt=1000.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=midpoint.vt=1000.dur=-5.post=nil => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=-5.post=-1 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=-5.post=0 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=1000.dur=-5.post=5 => reward=-2.5 post=5
    reward.r=true.ev=midpoint.vt=1000.dur=-5.post=2.5 => reward=-2.5 post=2.5
    reward.r=true.ev=midpoint.vt=1000.dur=40.5.post=nil => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=1000.dur=40.5.post=-1 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=1000.dur=40.5.post=0 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=1000.dur=40.5.post=5 => reward=20.25 post=25.25
    reward.r=true.ev=midpoint.vt=1000.dur=40.5.post=2.5 => reward=20.25 post=22.75
    reward.r=true.ev=midpoint.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=midpoint.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=midpoint.vt=2.5.dur=10.post=nil => reward=5 post=5
    reward.r=true.ev=midpoint.vt=2.5.dur=10.post=-1 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=2.5.dur=10.post=0 => reward=5 post=5
    reward.r=true.ev=midpoint.vt=2.5.dur=10.post=5 => reward=5 post=10
    reward.r=true.ev=midpoint.vt=2.5.dur=10.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=midpoint.vt=2.5.dur=-5.post=nil => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=-5.post=-1 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=-5.post=0 => reward=-2.5 post=0
    reward.r=true.ev=midpoint.vt=2.5.dur=-5.post=5 => reward=-2.5 post=5
    reward.r=true.ev=midpoint.vt=2.5.dur=-5.post=2.5 => reward=-2.5 post=2.5
    reward.r=true.ev=midpoint.vt=2.5.dur=40.5.post=nil => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=2.5.dur=40.5.post=-1 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=2.5.dur=40.5.post=0 => reward=20.25 post=20.25
    reward.r=true.ev=midpoint.vt=2.5.dur=40.5.post=5 => reward=20.25 post=25.25
    reward.r=true.ev=midpoint.vt=2.5.dur=40.5.post=2.5 => reward=20.25 post=22.75
    reward.r=true.ev=thirdquartile.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=nil.dur=10.post=nil => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=nil.dur=10.post=-1 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=nil.dur=10.post=0 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=nil.dur=10.post=5 => reward=7.5 post=12.5
    reward.r=true.ev=thirdquartile.vt=nil.dur=10.post=2.5 => reward=7.5 post=10
    reward.r=true.ev=thirdquartile.vt=nil.dur=-5.post=nil => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=-5.post=-1 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=-5.post=0 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=nil.dur=-5.post=5 => reward=-3.75 post=5
    reward.r=true.ev=thirdquartile.vt=nil.dur=-5.post=2.5 => reward=-3.75 post=2.5
    reward.r=true.ev=thirdquartile.vt=nil.dur=40.5.post=nil => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=nil.dur=40.5.post=-1 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=nil.dur=40.5.post=0 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=nil.dur=40.5.post=5 => reward=30.375 post=35.375
    reward.r=true.ev=thirdquartile.vt=nil.dur=40.5.post=2.5 => reward=30.375 post=32.875
    reward.r=true.ev=thirdquartile.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=-1.dur=10.post=nil => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=-1.dur=10.post=-1 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=-1.dur=10.post=0 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=-1.dur=10.post=5 => reward=7.5 post=12.5
    reward.r=true.ev=thirdquartile.vt=-1.dur=10.post=2.5 => reward=7.5 post=10
    reward.r=true.ev=thirdquartile.vt=-1.dur=-5.post=nil => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=-5.post=-1 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=-5.post=0 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=-1.dur=-5.post=5 => reward=-3.75 post=5
    reward.r=true.ev=thirdquartile.vt=-1.dur=-5.post=2.5 => reward=-3.75 post=2.5
    reward.r=true.ev=thirdquartile.vt=-1.dur=40.5.post=nil => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=-1.dur=40.5.post=-1 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=-1.dur=40.5.post=0 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=-1.dur=40.5.post=5 => reward=30.375 post=35.375
    reward.r=true.ev=thirdquartile.vt=-1.dur=40.5.post=2.5 => reward=30.375 post=32.875
    reward.r=true.ev=thirdquartile.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=0.dur=10.post=nil => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=0.dur=10.post=-1 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=0.dur=10.post=0 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=0.dur=10.post=5 => reward=7.5 post=12.5
    reward.r=true.ev=thirdquartile.vt=0.dur=10.post=2.5 => reward=7.5 post=10
    reward.r=true.ev=thirdquartile.vt=0.dur=-5.post=nil => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=-5.post=-1 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=-5.post=0 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=0.dur=-5.post=5 => reward=-3.75 post=5
    reward.r=true.ev=thirdquartile.vt=0.dur=-5.post=2.5 => reward=-3.75 post=2.5
    reward.r=true.ev=thirdquartile.vt=0.dur=40.5.post=nil => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=0.dur=40.5.post=-1 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=0.dur=40.5.post=0 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=0.dur=40.5.post=5 => reward=30.375 post=35.375
    reward.r=true.ev=thirdquartile.vt=0.dur=40.5.post=2.5 => reward=30.375 post=32.875
    reward.r=true.ev=thirdquartile.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=5.dur=10.post=nil => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=5.dur=10.post=-1 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=5.dur=10.post=0 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=5.dur=10.post=5 => reward=7.5 post=12.5
    reward.r=true.ev=thirdquartile.vt=5.dur=10.post=2.5 => reward=7.5 post=10
    reward.r=true.ev=thirdquartile.vt=5.dur=-5.post=nil => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=-5.post=-1 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=-5.post=0 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=5.dur=-5.post=5 => reward=-3.75 post=5
    reward.r=true.ev=thirdquartile.vt=5.dur=-5.post=2.5 => reward=-3.75 post=2.5
    reward.r=true.ev=thirdquartile.vt=5.dur=40.5.post=nil => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=5.dur=40.5.post=-1 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=5.dur=40.5.post=0 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=5.dur=40.5.post=5 => reward=30.375 post=35.375
    reward.r=true.ev=thirdquartile.vt=5.dur=40.5.post=2.5 => reward=30.375 post=32.875
    reward.r=true.ev=thirdquartile.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=100.dur=10.post=nil => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=100.dur=10.post=-1 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=100.dur=10.post=0 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=100.dur=10.post=5 => reward=7.5 post=12.5
    reward.r=true.ev=thirdquartile.vt=100.dur=10.post=2.5 => reward=7.5 post=10
    reward.r=true.ev=thirdquartile.vt=100.dur=-5.post=nil => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=-5.post=-1 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=-5.post=0 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=100.dur=-5.post=5 => reward=-3.75 post=5
    reward.r=true.ev=thirdquartile.vt=100.dur=-5.post=2.5 => reward=-3.75 post=2.5
    reward.r=true.ev=thirdquartile.vt=100.dur=40.5.post=nil => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=100.dur=40.5.post=-1 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=100.dur=40.5.post=0 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=100.dur=40.5.post=5 => reward=30.375 post=35.375
    reward.r=true.ev=thirdquartile.vt=100.dur=40.5.post=2.5 => reward=30.375 post=32.875
    reward.r=true.ev=thirdquartile.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=1000.dur=10.post=nil => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=1000.dur=10.post=-1 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=1000.dur=10.post=0 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=1000.dur=10.post=5 => reward=7.5 post=12.5
    reward.r=true.ev=thirdquartile.vt=1000.dur=10.post=2.5 => reward=7.5 post=10
    reward.r=true.ev=thirdquartile.vt=1000.dur=-5.post=nil => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=-5.post=-1 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=-5.post=0 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=1000.dur=-5.post=5 => reward=-3.75 post=5
    reward.r=true.ev=thirdquartile.vt=1000.dur=-5.post=2.5 => reward=-3.75 post=2.5
    reward.r=true.ev=thirdquartile.vt=1000.dur=40.5.post=nil => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=1000.dur=40.5.post=-1 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=1000.dur=40.5.post=0 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=1000.dur=40.5.post=5 => reward=30.375 post=35.375
    reward.r=true.ev=thirdquartile.vt=1000.dur=40.5.post=2.5 => reward=30.375 post=32.875
    reward.r=true.ev=thirdquartile.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=10.post=nil => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=10.post=-1 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=10.post=0 => reward=7.5 post=7.5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=10.post=5 => reward=7.5 post=12.5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=10.post=2.5 => reward=7.5 post=10
    reward.r=true.ev=thirdquartile.vt=2.5.dur=-5.post=nil => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=-5.post=-1 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=-5.post=0 => reward=-3.75 post=0
    reward.r=true.ev=thirdquartile.vt=2.5.dur=-5.post=5 => reward=-3.75 post=5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=-5.post=2.5 => reward=-3.75 post=2.5
    reward.r=true.ev=thirdquartile.vt=2.5.dur=40.5.post=nil => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=2.5.dur=40.5.post=-1 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=2.5.dur=40.5.post=0 => reward=30.375 post=30.375
    reward.r=true.ev=thirdquartile.vt=2.5.dur=40.5.post=5 => reward=30.375 post=35.375
    reward.r=true.ev=thirdquartile.vt=2.5.dur=40.5.post=2.5 => reward=30.375 post=32.875
    reward.r=true.ev=complete.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=nil.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=complete.vt=nil.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=complete.vt=nil.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=complete.vt=nil.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=complete.vt=nil.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=complete.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=nil.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=complete.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=nil.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=complete.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=-1.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=complete.vt=-1.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=complete.vt=-1.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=complete.vt=-1.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=complete.vt=-1.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=complete.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=-1.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=complete.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=-1.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=complete.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=0.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=complete.vt=0.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=complete.vt=0.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=complete.vt=0.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=complete.vt=0.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=complete.vt=0.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=0.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=complete.vt=0.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=0.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=complete.vt=0.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=0.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=0.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=0.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=0.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=complete.vt=0.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=complete.vt=5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=complete.vt=5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=complete.vt=5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=complete.vt=5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=complete.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=complete.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=complete.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=100.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=complete.vt=100.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=complete.vt=100.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=complete.vt=100.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=complete.vt=100.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=complete.vt=100.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=100.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=complete.vt=100.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=100.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=complete.vt=100.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=100.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=100.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=100.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=100.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=complete.vt=100.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=1000.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=complete.vt=1000.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=complete.vt=1000.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=complete.vt=1000.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=complete.vt=1000.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=complete.vt=1000.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=1000.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=complete.vt=1000.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=1000.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=complete.vt=1000.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=1000.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=1000.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=1000.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=1000.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=complete.vt=1000.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=complete.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=2.5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=complete.vt=2.5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=complete.vt=2.5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=complete.vt=2.5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=complete.vt=2.5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=nil.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=bogus.vt=nil.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=bogus.vt=nil.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=bogus.vt=nil.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=bogus.vt=nil.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=-1.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=bogus.vt=-1.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=bogus.vt=-1.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=bogus.vt=-1.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=bogus.vt=-1.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=0.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=bogus.vt=0.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=bogus.vt=0.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=bogus.vt=0.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=bogus.vt=0.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=bogus.vt=0.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=0.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=0.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=0.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=bogus.vt=0.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=0.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=0.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=0.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=0.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=bogus.vt=0.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=bogus.vt=5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=bogus.vt=5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=bogus.vt=5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=bogus.vt=5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=bogus.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=bogus.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=100.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=bogus.vt=100.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=bogus.vt=100.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=bogus.vt=100.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=bogus.vt=100.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=bogus.vt=100.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=100.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=100.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=100.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=bogus.vt=100.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=100.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=100.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=100.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=100.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=bogus.vt=100.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=1000.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=bogus.vt=1000.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=bogus.vt=1000.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=bogus.vt=1000.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=bogus.vt=1000.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=bogus.vt=1000.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=1000.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=1000.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=1000.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=bogus.vt=1000.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=1000.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=1000.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=1000.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=1000.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=bogus.vt=1000.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=bogus.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=2.5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=bogus.vt=2.5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=bogus.vt=2.5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=bogus.vt=2.5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=bogus.vt=2.5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=unknown.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=nil.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=unknown.vt=nil.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=unknown.vt=nil.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=unknown.vt=nil.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=unknown.vt=nil.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=unknown.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=unknown.vt=nil.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=nil.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=unknown.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=unknown.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=nil.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=nil.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=unknown.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=unknown.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=-1.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=unknown.vt=-1.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=unknown.vt=-1.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=unknown.vt=-1.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=unknown.vt=-1.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=unknown.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=unknown.vt=-1.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=-1.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=unknown.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=unknown.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=-1.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=-1.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=unknown.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=unknown.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=0.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=unknown.vt=0.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=unknown.vt=0.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=unknown.vt=0.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=unknown.vt=0.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=unknown.vt=0.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=unknown.vt=0.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=0.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=0.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=unknown.vt=0.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=unknown.vt=0.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=0.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=0.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=0.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=unknown.vt=0.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=unknown.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=unknown.vt=5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=unknown.vt=5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=unknown.vt=5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=unknown.vt=5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=unknown.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=unknown.vt=5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=unknown.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=unknown.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=unknown.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=unknown.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=100.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=unknown.vt=100.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=unknown.vt=100.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=unknown.vt=100.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=unknown.vt=100.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=unknown.vt=100.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=unknown.vt=100.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=100.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=100.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=unknown.vt=100.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=unknown.vt=100.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=100.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=100.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=100.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=unknown.vt=100.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=unknown.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=1000.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=unknown.vt=1000.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=unknown.vt=1000.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=unknown.vt=1000.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=unknown.vt=1000.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=unknown.vt=1000.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=unknown.vt=1000.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=1000.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=1000.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=unknown.vt=1000.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=unknown.vt=1000.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=1000.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=1000.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=1000.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=unknown.vt=1000.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=unknown.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=unknown.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=unknown.vt=2.5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=unknown.vt=2.5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=unknown.vt=2.5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=unknown.vt=2.5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=unknown.vt=2.5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=unknown.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=unknown.vt=2.5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=unknown.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=unknown.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=2.5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=unknown.vt=2.5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=unknown.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=nil.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=.vt=nil.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=.vt=nil.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=.vt=nil.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=.vt=nil.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=.vt=nil.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=.vt=nil.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=.vt=nil.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=nil.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=-1.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=.vt=-1.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=.vt=-1.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=.vt=-1.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=.vt=-1.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=.vt=-1.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=.vt=-1.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=.vt=-1.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=-1.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=0.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=.vt=0.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=.vt=0.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=.vt=0.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=.vt=0.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=.vt=0.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=.vt=0.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=.vt=0.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=.vt=0.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=.vt=0.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=.vt=0.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=.vt=0.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=0.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=0.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=.vt=0.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=.vt=5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=.vt=5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=.vt=5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=.vt=5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=.vt=5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=.vt=5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=.vt=5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=100.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=.vt=100.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=.vt=100.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=.vt=100.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=.vt=100.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=.vt=100.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=.vt=100.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=.vt=100.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=.vt=100.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=.vt=100.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=.vt=100.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=.vt=100.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=100.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=100.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=.vt=100.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=1000.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=.vt=1000.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=.vt=1000.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=.vt=1000.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=.vt=1000.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=.vt=1000.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=.vt=1000.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=.vt=1000.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=.vt=1000.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=.vt=1000.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=.vt=1000.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=.vt=1000.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=1000.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=1000.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=.vt=1000.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=.vt=2.5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=.vt=2.5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=.vt=2.5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=.vt=2.5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=.vt=2.5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=.vt=2.5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=.vt=2.5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=.vt=2.5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=.vt=2.5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=creativeView.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=nil.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=creativeView.vt=nil.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=nil.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=nil.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=creativeView.vt=nil.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=creativeView.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=nil.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=creativeView.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=creativeView.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=nil.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=nil.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=creativeView.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=creativeView.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=-1.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=creativeView.vt=-1.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=-1.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=-1.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=creativeView.vt=-1.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=creativeView.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=-1.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=creativeView.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=creativeView.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=-1.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=-1.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=creativeView.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=creativeView.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=0.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=creativeView.vt=0.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=0.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=0.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=creativeView.vt=0.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=creativeView.vt=0.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=0.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=0.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=0.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=creativeView.vt=0.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=creativeView.vt=0.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=0.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=0.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=0.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=creativeView.vt=0.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=creativeView.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=creativeView.vt=5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=creativeView.vt=5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=creativeView.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=creativeView.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=creativeView.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=creativeView.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=creativeView.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=100.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=creativeView.vt=100.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=100.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=100.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=creativeView.vt=100.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=creativeView.vt=100.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=100.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=100.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=100.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=creativeView.vt=100.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=creativeView.vt=100.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=100.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=100.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=100.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=creativeView.vt=100.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=creativeView.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=1000.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=creativeView.vt=1000.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=1000.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=1000.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=creativeView.vt=1000.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=creativeView.vt=1000.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=1000.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=creativeView.vt=1000.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=creativeView.vt=1000.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=1000.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=1000.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=1000.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=creativeView.vt=1000.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=creativeView.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=creativeView.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=creativeView.vt=2.5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=creativeView.vt=2.5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=2.5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=creativeView.vt=2.5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=creativeView.vt=2.5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=creativeView.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=creativeView.vt=2.5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=creativeView.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=creativeView.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=2.5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=creativeView.vt=2.5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=creativeView.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=Complete.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=nil.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=nil.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=nil.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=nil.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=nil.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=nil.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=nil.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=nil.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=Complete.vt=nil.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=Complete.vt=nil.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=Complete.vt=nil.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=Complete.vt=nil.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=Complete.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=Complete.vt=nil.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=nil.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=Complete.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=Complete.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=nil.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=nil.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=Complete.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=Complete.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=-1.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=-1.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=-1.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=-1.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=-1.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=-1.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=-1.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=-1.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=Complete.vt=-1.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=Complete.vt=-1.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=Complete.vt=-1.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=Complete.vt=-1.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=Complete.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=Complete.vt=-1.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=-1.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=Complete.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=Complete.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=-1.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=-1.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=Complete.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=Complete.vt=0.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=0.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=0.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=0.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=0.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=0.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=0.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=0.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=0.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=0.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=0.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=Complete.vt=0.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=Complete.vt=0.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=Complete.vt=0.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=Complete.vt=0.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=Complete.vt=0.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=Complete.vt=0.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=0.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=0.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=Complete.vt=0.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=Complete.vt=0.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=0.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=0.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=0.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=Complete.vt=0.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=Complete.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=Complete.vt=5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=Complete.vt=5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=Complete.vt=5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=Complete.vt=5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=Complete.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=Complete.vt=5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=Complete.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=Complete.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=Complete.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=Complete.vt=100.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=100.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=100.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=100.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=100.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=100.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=100.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=100.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=100.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=100.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=100.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=Complete.vt=100.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=Complete.vt=100.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=Complete.vt=100.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=Complete.vt=100.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=Complete.vt=100.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=Complete.vt=100.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=100.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=100.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=Complete.vt=100.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=Complete.vt=100.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=100.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=100.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=100.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=Complete.vt=100.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=Complete.vt=1000.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=1000.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=1000.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=1000.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=1000.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=1000.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=1000.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=1000.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=1000.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=1000.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=1000.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=Complete.vt=1000.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=Complete.vt=1000.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=Complete.vt=1000.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=Complete.vt=1000.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=Complete.vt=1000.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=Complete.vt=1000.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=1000.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=1000.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=Complete.vt=1000.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=Complete.vt=1000.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=1000.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=1000.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=1000.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=Complete.vt=1000.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=Complete.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=nil.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=nil.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=2.5.dur=0.post=nil => reward=0 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=0.post=-1 => reward=0 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=0.post=0 => reward=0 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=0.post=5 => reward=0 post=5
    reward.r=true.ev=Complete.vt=2.5.dur=0.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=Complete.vt=2.5.dur=10.post=nil => reward=10 post=10
    reward.r=true.ev=Complete.vt=2.5.dur=10.post=-1 => reward=10 post=10
    reward.r=true.ev=Complete.vt=2.5.dur=10.post=0 => reward=10 post=10
    reward.r=true.ev=Complete.vt=2.5.dur=10.post=5 => reward=10 post=15
    reward.r=true.ev=Complete.vt=2.5.dur=10.post=2.5 => reward=10 post=12.5
    reward.r=true.ev=Complete.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=-5.post=-1 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=Complete.vt=2.5.dur=-5.post=5 => reward=-5 post=5
    reward.r=true.ev=Complete.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=Complete.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=2.5.dur=40.5.post=-1 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=Complete.vt=2.5.dur=40.5.post=5 => reward=40.5 post=45.5
    reward.r=true.ev=Complete.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.noconfig => reward=12 post=12
    """.components(separatedBy: "\n")
}
