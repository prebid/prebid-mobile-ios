import Foundation

@objcMembers
public class NativoBidResponse: BidResponse {

    required init(rawBidResponse: RawBidResponse?) {
        super.init(rawBidResponse: rawBidResponse)
    }
    
    // Create bid using NativoBid
    override func createBids(rawBidResponse: RawBidResponse) {
        var allBids: [Bid] = []
        if let seatbid = rawBidResponse.seatbid {
            for nextSeatBid in seatbid {
                guard let bids = nextSeatBid.bid else { continue }
                for nextBid in bids {
                    let bid = NativoBid(bid: nextBid)
                    allBids.append(bid)
                    
                    // Select Nativo's winning bid
                    if bid.price > self.winningBid?.price ?? 0 {
                        self.winningBid = bid
                    }
                }
            }
        }
        self.allBids = allBids
        
        /**
            Mimic targeting parameters sent from prebid server
            hb_env=mobile-app&hb_env_nativo=mobile-app&hb_bidder=nativo&hb_size=300x250&hb_pb_nativo=1.00&hb_bidder_nativo=nativo&hb_size_nativo=300x250&hb_pb=1.00
         */
        if let winningBid = self.winningBid {
            var targeting = [String : String]()
            targeting["hb_env"] = "mobile-app"
            targeting["hb_env_nativo"] = "mobile-app"
            let size = winningBid.size
            targeting["hb_size"] = "\(size.width)x\(size.height)"
            targeting["hb_size_nativo"] = "\(size.width)x\(size.height)"
            targeting["hb_bidder"] = "nativo"
            targeting["hb_bidder_nativo"] = "nativo"
            targeting["hb_pb"] = "\(winningBid.price)"
            targeting["hb_pb_nativo"] = "\(winningBid.price)"
            self.targetingInfo = targeting
        }
    }
}
