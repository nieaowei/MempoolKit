import XCTest
@testable import MempoolKit

final class MempoolKitTests: XCTestCase {
    
    @available(iOS 13.0, *)
    func delay(sec: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(sec * 1_000_000_000))
    }
    
    // Difficulty Adjustment
    
    @available(iOS 13.0.0, *)
    func testDifficultyAdjustment() async throws {
        let mempool = Mempool()
        let _ = try await mempool.difficultyAdjustment()
    }
    
    // Blocks
    @available(iOS 13.0.0, *)
    func testBlocks() async throws {
        let mempool = Mempool()
        _ = try await mempool.blockTipHash()
        _ = try await mempool.blockTipHeight()
        let randomBlock = Int.random(in: 10...100000)
        for i in (randomBlock-10)...randomBlock {
            try await delay(sec: 0.5)
            print("i=\(i)")
            let blockHash = try await mempool.blockHeight(blockHeight: i)
            let _ = try await mempool.block(blockHash: blockHash)
            let _ = try await mempool.blocks(blockHeight: i)
            let _ = try await mempool.blockHeader(blockHash: blockHash)
            let _ = try await mempool.blockRaw(blockHash: blockHash)
            let _ = try await mempool.blockStatus(blockHash: blockHash)
            let _ = try await mempool.blockTXID(blockHash: blockHash, index: 1)
            let _ = try await mempool.blockTXs(blockHash: blockHash)
            let blockTXIDs = try await mempool.blockTXIDs(blockHash: blockHash)
            for tx in blockTXIDs {
                try await delay(sec: 0.05)
                print("tx=\(tx)")
                try await testTransaction(txid: tx)
            }
        }
    }
    
    // Transactions
    
    @available(iOS 13.0.0, *)
    func testTransaction(txid: String) async throws {
        let mempool = Mempool()
        let _ = try await mempool.transactionHex(txid: txid)
        let _ = try await mempool.transactionMerkleBlockProof(txid: txid)
        let _ = try await mempool.transactionMerkleProof(txid: txid)
        let _ = try await mempool.transactionOutspends(txid: txid)
        let _ = try await mempool.transactionRaw(txid: txid)
        let _ = try await mempool.transactionStatus(txid: txid)
        let tx = try await mempool.transaction(txid: txid)
        for output in tx.vout {
            if let scriptpubkey_address = output.scriptpubkey_address {
                try await address(address: scriptpubkey_address)
            }
        }
    }
    
    // Addresses
    
    @available(iOS 13.0.0, *)
    func address(address: String) async throws {
        let mempool = Mempool()
        _ = try await mempool.address(address: address)
        let txs = try await mempool.addressTXS(address: address)
        _ = try await mempool.addressTXSChain(address: address, lastTXID: txs.first!.txid)
        _ = try await mempool.addressTXSMempool(address: address)
        _ = try await mempool.addressUTXOs(address: address)
    }
    
    // Mining
    
    @available(iOS 13.0.0, *)
    func testMining() async throws {
        let mempool = Mempool()
        _ = try await mempool.miningPools(time: .oneYear)
        _ = try await mempool.miningPool(miningPool: "AntPool")
        _ = try await mempool.miningPoolHashrates(time: .oneYear)
        _ = try await mempool.miningPoolHashrate(miningPool: "AntPool")
        _ = try await mempool.miningPoolBlocks(miningPool: "AntPool", blockHeight: 730000)
        _ = try await mempool.miningHashrate(time: .oneYear)
        _ = try await mempool.miningRewardStats(blockCount: 100)
        _ = try await mempool.blockFees(time: .oneYear)
        _ = try await mempool.blockRewards(time: .oneYear)
        _ = try await mempool.blockFeeRates(time: .oneYear)
        _ = try await mempool.blockSizeAndWeights(time: .oneYear)
    }
    
    // Mempool
    
    @available(iOS 13.0.0, *)
    func testMempool() async throws {
        let mempool = Mempool()
        _ = try await mempool.mempool()
        _ = try await mempool.mempoolTXIDs()
        _ = try await mempool.mempoolRecent()
    }
    
    // Lightning
    
    @available(iOS 13.0.0, *)
    func testLightning() async throws {
        let mempool = Mempool()
        _ = try await mempool.lightningStatistic(time: .oneYear)
        let top100Nodes = try await mempool.lightningTop100Nodes()
        for node in top100Nodes.topByCapacity {
            _ = try await mempool.lightningNodes(node: node.alias)
        }
        _ = try await mempool.lightningNodesInCountry(country: .us)
        _ = try await mempool.lightningNodesStatisticsPerCountry()
        _ = try await mempool.lightningISP(isp: 16509)
        _ = try await mempool.lightningNodeStatisticPerISP()
        _ = try await mempool.lightningTop100NodesByLiquidity()
        _ = try await mempool.lightningTop100NodesByConnectivity()
        _ = try await mempool.lightningTop100OldestNodes()
        _ = try await mempool.lightningNodeStatistic(pubKey: "03864ef025fde8fb587d989186ce6a4a186895ee44a926bfc370e2c366597a3f8f")
        _ = try await mempool.lightningHistoricalNodeStatistics(pubKey: "03864ef025fde8fb587d989186ce6a4a186895ee44a926bfc370e2c366597a3f8f")
        _ = try await mempool.lightningChannel(channelID: "855515703977115663")
        _ = try await mempool.lightningChannelTXID(txid: "f95aea73705256e0d31ca722bda3e350f411590cd2e5222fb3be23912834495a")
        _ = try await mempool.lightningChannelFromNodePubkey(pubkey: "855515703977115663", channelStatus: .open)
    }
    
    @available(iOS 13.0.0, *)
    func testCustomServer() async throws {
        
        // Public Mempool Server
        // https://mempool.space
        // http://xtrum.com
        // https://bitcoin.lu.ke
        
        
        let a = Mempool(server: "http://xtrum.com", debugMode: true)
        var index = 0
        while index < 1000 {
            let blocks = try await a.blocks(blockHeight: index)
            print(blocks.map({ i in
                i.id
            }))
            index += 15
        }
    }
    
    @available(iOS 13.0.0, *)
    func testLightningNodeIPAddress() async throws {
        let mempool = Mempool()
        let node = try await mempool.lightningNodeStatistic(pubKey: "03864ef025fde8fb587d989186ce6a4a186895ee44a926bfc370e2c366597a3f8f")
        print(node.sockets)
    }
    
    @available(iOS 13.0.0, *)
    func testNetTest() async throws {
        let mempool = Mempool(network: .testnet, debugMode: true)
        let fees = try await mempool.addressTXS(address: "mgWFkrrMys8XCcZRzP21sHc7xQU7nkcc1H")
        print(fees)
    }
    
    @available(iOS 13.0.0, *)
    func testTestnetLightningNodes() async throws {
        let mempool = Mempool(network: .testnet, debugMode: true)
        let nodes = try await mempool.lightningTop100Nodes()
        print(nodes.topByCapacity)
    }
    
    @available(iOS 13.0.0, *)
    func testTestnetLightningNode() async throws {
        let mempool = Mempool(network: .testnet, debugMode: true)
        let node = try await mempool.lightningNodeStatistic(pubKey: "038863cf8ab91046230f561cd5b386cbff8309fa02e3f0c3ed161a3aeb64a643b9")
        print(node)
    }
}




