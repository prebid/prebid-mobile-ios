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
    close.comp=false.skip=nil.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=nil.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=nil.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=nil.off=nil.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=nil.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=nil.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=nil.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=nil.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=nil.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=nil.off=4.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=4.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=4.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=4.dur=inf.pub=nan => 10
    close.comp=false.skip=nil.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=nil.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=nil.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=nil.off=-1.dur=60.pub=0 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=5 => 10
    close.comp=false.skip=nil.off=-1.dur=60.pub=nan => 10
    close.comp=false.skip=nil.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=nil.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=nil.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=nil.off=-1.dur=inf.pub=0 => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=5 => 10
    close.comp=false.skip=nil.off=-1.dur=inf.pub=nan => 10
    close.comp=false.skip=5.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=5.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=5.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=5.off=nil.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=nil.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=nil.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=5.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=5.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=5.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=5.off=4.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=4.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=4.dur=inf.pub=nan => 5
    close.comp=false.skip=5.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=5.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=5.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=5.off=-1.dur=60.pub=0 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=60.pub=nan => 5
    close.comp=false.skip=5.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=5.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=5.off=-1.dur=inf.pub=0 => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=5 => 5
    close.comp=false.skip=5.off=-1.dur=inf.pub=nan => 5
    close.comp=false.skip=nan.off=nil.dur=nil.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=5 => 2
    close.comp=false.skip=nan.off=nil.dur=nil.pub=nan => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=5 => 2
    close.comp=false.skip=nan.off=nil.dur=0.pub=nan => 2
    close.comp=false.skip=nan.off=nil.dur=60.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=60.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=60.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=nil.dur=inf.pub=0 => 2
    close.comp=false.skip=nan.off=nil.dur=inf.pub=5 => 5
    close.comp=false.skip=nan.off=nil.dur=inf.pub=nan => nan
    close.comp=false.skip=nan.off=4.dur=nil.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=5 => 2
    close.comp=false.skip=nan.off=4.dur=nil.pub=nan => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=5 => 2
    close.comp=false.skip=nan.off=4.dur=0.pub=nan => 2
    close.comp=false.skip=nan.off=4.dur=60.pub=0 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=5 => 4
    close.comp=false.skip=nan.off=4.dur=60.pub=nan => 4
    close.comp=false.skip=nan.off=4.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=4.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=4.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=4.dur=inf.pub=0 => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=5 => 4
    close.comp=false.skip=nan.off=4.dur=inf.pub=nan => 4
    close.comp=false.skip=nan.off=-1.dur=nil.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=nil.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=0.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=60.pub=nan => -1
    close.comp=false.skip=nan.off=-1.dur=nan.pub=0 => 2
    close.comp=false.skip=nan.off=-1.dur=nan.pub=5 => 5
    close.comp=false.skip=nan.off=-1.dur=nan.pub=nan => nan
    close.comp=false.skip=nan.off=-1.dur=inf.pub=0 => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=5 => -1
    close.comp=false.skip=nan.off=-1.dur=inf.pub=nan => -1
    close.comp=true.skip=nil.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=nil.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=nil.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=nil.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=nil.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=nil.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=nil.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=nil.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=nil.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=nil.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=5.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=5.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=5.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=5.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=5.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=5.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=5.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=5.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=5.off=-1.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=nil.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=nil.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=nil.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=nil.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=nil.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=nil.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=nil.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=nil.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=nil.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=4.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=4.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=4.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=4.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=4.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=4.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=4.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=4.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=4.dur=inf.pub=nan => inf
    close.comp=true.skip=nan.off=-1.dur=nil.pub=0 => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=5 => 0
    close.comp=true.skip=nan.off=-1.dur=nil.pub=nan => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=0 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=5 => 0
    close.comp=true.skip=nan.off=-1.dur=0.pub=nan => 0
    close.comp=true.skip=nan.off=-1.dur=60.pub=0 => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=5 => 60
    close.comp=true.skip=nan.off=-1.dur=60.pub=nan => 60
    close.comp=true.skip=nan.off=-1.dur=nan.pub=0 => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=5 => nan
    close.comp=true.skip=nan.off=-1.dur=nan.pub=nan => nan
    close.comp=true.skip=nan.off=-1.dur=inf.pub=0 => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=5 => inf
    close.comp=true.skip=nan.off=-1.dur=inf.pub=nan => inf
    reward.r=false.ev=nil.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=nil.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=start.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=complete.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=nil.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=-1.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=nil.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=-5.post=2.5 => reward=-1 post=2.5
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=nil => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=0 => reward=-1 post=0
    reward.r=false.ev=bogus.vt=2.5.dur=40.5.post=2.5 => reward=-1 post=2.5
    reward.r=true.ev=nil.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=nil.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=nil.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=nil.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=5.dur=40.5.post=nil => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=40.5.post=0 => reward=5 post=5
    reward.r=true.ev=nil.vt=5.dur=40.5.post=2.5 => reward=5 post=7.5
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=nil.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=nil.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=nil => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=0 => reward=2.5 post=2.5
    reward.r=true.ev=nil.vt=2.5.dur=40.5.post=2.5 => reward=2.5 post=5
    reward.r=true.ev=start.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=nil.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=nil.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=nil.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=-1.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=-1.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=5.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=5.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=-5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=-5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=-5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=nil => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=0 => reward=0 post=0
    reward.r=true.ev=start.vt=2.5.dur=40.5.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=complete.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=complete.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=complete.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=nil.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=nil.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=nil.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=-1.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=-1.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=-1.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=nil => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=0 => reward=0 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=nil.post=2.5 => reward=0 post=2.5
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=nil => reward=-5 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=0 => reward=-5 post=0
    reward.r=true.ev=bogus.vt=2.5.dur=-5.post=2.5 => reward=-5 post=2.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=nil => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=0 => reward=40.5 post=40.5
    reward.r=true.ev=bogus.vt=2.5.dur=40.5.post=2.5 => reward=40.5 post=43
    reward.noconfig => reward=12 post=12
    """.components(separatedBy: "\n")
}
