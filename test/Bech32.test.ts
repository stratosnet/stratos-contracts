import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { expectRevert } from "@openzeppelin/test-helpers";


import { AddressConvertMock as AddressConvertMockType } from "../typechain-types";


enum Bech32Enc {
  NULL = null,
  DEFAULT = 1,
  M = 0x2bc830a3,
}

interface WalletType {
  address: string;
  encoding: Bech32Enc;
}

const VALID_CHECKSUM_BECH32 = [
  "A12UEL5L",
  "a12uel5l",
  "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
  "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
  "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
  "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
  "?1ezyfcl",
];

const VALID_CHECKSUM_BECH32M = [
  "A1LQFN3A",
  "a1lqfn3a",
  "an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6",
  "abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx",
  "11llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllludsr8",
  "split1checkupstagehandshakeupstreamerranterredcaperredlc445v",
  "?1v759aa",
];

const INVALID_CHECKSUM_BECH32 = [
  " 1nwldj5",
  "\x7f" + "1axkwrx",
  "\x80" + "1eym55h",
  "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
  "pzry9x0s0muk",
  "1pzry9x0s0muk",
  "x1b4n0q5v",
  "li1dgmt3",
  "de1lg7wt\xff",
  "A1G7SGD8",
  "10a06t8",
  "1qzzfhee",
];

const INVALID_CHECKSUM_BECH32M = [
  " 1xj0phk",
  "\x7F" + "1g6xzxy",
  "\x80" + "1vctc34",
  "an84characterslonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11d6pts4",
  "qyrz8wqd2c9m",
  "1qyrz8wqd2c9m",
  "y1b0jsk6g",
  "lt1igcx5c0",
  "in1muywd",
  "mm1crxm3i",
  "au1s5cgom",
  "M1VUXWEZ",
  "16plkw9",
  "1p2gdwpf",
]

const VALID_ADDRESS: WalletType[] = [
  {
    address: "cosmos1clxhdlzj8jfemdlqaxq5k2qkt07tnmdt3r707m",
    encoding: Bech32Enc.NULL,
  },
  {
    address: "st1wf0rlsj3hwz0va3fu8jp8s2xmx3hwqfzgkhxa0",
    encoding: Bech32Enc.NULL,
  },
  {
    address: "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4",
    encoding: Bech32Enc.DEFAULT,
  },
  {
    address: "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
    encoding: Bech32Enc.DEFAULT,
  },
  {
    address: "bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kt5nd6y",
    encoding: Bech32Enc.M,
  },
  {
    address: "BC1SW50QGDZ25J",
    encoding: Bech32Enc.M,
  },
  {
    address: "bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs",
    encoding: Bech32Enc.M,
  },
  {
    address: "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
    encoding: Bech32Enc.DEFAULT,
  },
  {
    address: "tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c",
    encoding: Bech32Enc.M,
  },
  {
    address: "bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0",
    encoding: Bech32Enc.M,
  },
];

describe("Bech32", function () {

  async function deployAcmFixture() {
    const [owner] = await ethers.getSigners();

    const defaultPrefix = "st";
    const AddressConvertMock = await ethers.getContractFactory("AddressConvertMock");
    const acm: AddressConvertMockType = await AddressConvertMock.deploy(defaultPrefix);

    return { acm, owner, defaultPrefix };
  }

  it("should be ok with valid addresses on decode and encode back", async function () {
    const { acm } = await loadFixture(deployAcmFixture);

    for (let p = 0; p < VALID_ADDRESS.length; ++p) {
      const { address: bechAddress, encoding } = VALID_ADDRESS[p];
      const hrp = bechAddress.slice(0, bechAddress.indexOf('1')).toLowerCase();
      let recBechAddress: string;
      console.log(`Verify "${bechAddress}" address with hrp "${hrp}" on validity...`);
      if (encoding) {
        const [version, data] = await acm.callStatic.convertFromBech32ToData(hrp, bechAddress, encoding);
        recBechAddress = await acm.callStatic["convertFromDataToBech32(string,uint8,bytes)"](hrp, version, data);
      } else {
        const ethAddress = await acm.callStatic["convertFromBech32ToAddress(string,string)"](hrp, bechAddress);
        recBechAddress = await acm.callStatic["convertFromAddressToBech32(string,address)"](hrp, ethAddress);
      }
      expect(bechAddress.toLowerCase()).to.be.equal(recBechAddress);
      console.log(`Validation "${bechAddress}" passed ✅`);
    }
  });

  it("should be ok with valid bech32 checksum on decode", async function () {
    const { acm } = await loadFixture(deployAcmFixture);

    for (let p = 0; p < VALID_CHECKSUM_BECH32.length; ++p) {
      const bechAddress = VALID_CHECKSUM_BECH32[p];
      console.log(`Verify Bech32 "${bechAddress}" address on checksum...`);
      const enc = new TextEncoder();
      await acm.callStatic.decode(enc.encode(bechAddress), Bech32Enc.DEFAULT);
      console.log(`Checksum "${bechAddress}" passed ✅`);
    }
  });

  it("should be ok with valid bech32m checksum on decode", async function () {
    const { acm } = await loadFixture(deployAcmFixture);

    for (let p = 0; p < VALID_CHECKSUM_BECH32M.length; ++p) {
      const bechAddress = VALID_CHECKSUM_BECH32M[p];
      console.log(`Verify Bech32M "${bechAddress}" address on checksum...`);
      const enc = new TextEncoder();
      await acm.callStatic.decode(enc.encode(bechAddress), Bech32Enc.M);
      console.log(`Checksum "${bechAddress}" passed ✅`);
    }
  });

  it("should be failed with invalid bech32 checksum on decode", async function () {
    const { acm } = await loadFixture(deployAcmFixture);

    for (let p = 0; p < INVALID_CHECKSUM_BECH32.length; ++p) {
      const bechAddress = INVALID_CHECKSUM_BECH32[p];
      console.log(`Failing verification on Bech32 "${bechAddress}" address on checksum...`);
      const enc = new TextEncoder();

      await expectRevert.unspecified(
        acm.callStatic.decode(enc.encode(bechAddress), Bech32Enc.DEFAULT)
      );
      console.log(`Verification failed on Bech32 "${bechAddress}" address ✅`);
    }
  });

  it("should be failed with invalid bech32m checksum on decode", async function () {
    const { acm } = await loadFixture(deployAcmFixture);

    for (let p = 0; p < INVALID_CHECKSUM_BECH32M.length; ++p) {
      const bechAddress = INVALID_CHECKSUM_BECH32M[p];
      console.log(`Failing verification on Bech32M "${bechAddress}" address on checksum...`);
      const enc = new TextEncoder();

      await expectRevert.unspecified(
        acm.callStatic.decode(enc.encode(bechAddress), Bech32Enc.M)
      );
      console.log(`Verification failed on Bech32M "${bechAddress}" address ✅`);
    }
  });
});
