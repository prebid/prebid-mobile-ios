# A sample Open RTB 2.5 spec compliant request that Prebid Server Adapter would send out is as following:
```
{
  "app": {
    "bundle": "AppNexus.PrebidMobileDemo",
    "ext": {
      "prebid": {
        "version": "0.1.1",
        "source": "prebid-mobile"
      }
    },
    "publisher": {
      "id": "aecd6ef7-b992-4e99-9bb8-65e2d984e1dd"
    },
    "ver": "1.0"
  },
  "id": "7187C1AD-125E-4640-BD03-071D52F14CDF",
  "device": {
    "w": 375,
    "h": 667,
    "ifa": "9F8C747A-E09B-424F-8397-99390B75D2E1",
    "devtime": 1517328032,
    "osv": "10.2",
    "lmt": 0,
    "connectiontype": 1,
    "os": "iOS",
    "pxratio": 2,
    "make": "Apple",
    "ua": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Mobile/14C89",
    "model": "x86_64"
  },
  "ext": {
    "prebid": {
      "targeting": {
        "pricegranularity": "medium",
        "lengthmax": 20
      }
    }
  },
  "user": {
    "yob": 1993,
    "gender": "F"
  },
  "imp": [
    {
      "id": "HomeScreen",
      "ext": {
        "prebid": {
          "storedrequest": {
            "id": "eebc307d-7f76-45d6-a7a7-68985169b138"
          }
        }
      },
      "secure": 1,
      "banner": {
        "format": [
          {
            "w": 300,
            "h": 250
          }
        ]
      }
    }
  ]
}

```
