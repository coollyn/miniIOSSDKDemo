import UIKit
import AVEngine
import UniformTypeIdentifiers
import AVFoundation
import CryptoKit

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    private var engineHandle: NSNumber?
    private var AVEngineAssets = "AVEngineAssets/"
    private var dstVideoFile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        prepareFile()
        setupStartButton()
    }
    
    private func setupStartButton() {
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start", for: .normal)
        startButton.addTarget(self, action: #selector(startEngine), for: .touchUpInside)
        startButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        startButton.center = view.center
        view.addSubview(startButton)
    }
    
    @objc private func startEngine() {
        engineHandle = AVEngine.createEngine(dstVideoFile)
        if engineHandle != nil {
            print("Engine created successfully with handle: \(engineHandle!)")
        } else {
            print("Failed to create engine")
            return
        }
    }
    
    func prepareFile() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let assetsDir = documentsURL.appendingPathComponent(AVEngineAssets)
        try? FileManager.default.createDirectory(
            at: assetsDir,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o777]
        )
        
        let srcVideoFile =  "video-raw.mp4"
        
        if let srcURL = Bundle.main.url(forResource: srcVideoFile, withExtension: nil) {
            let dstURL = assetsDir.appendingPathComponent(srcVideoFile)
            try? FileManager.default.copyItem(at: srcURL, to: dstURL)
            try? FileManager.default.setAttributes([.posixPermissions: 0o666], ofItemAtPath: dstURL.path)
            try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: dstURL.path)
                        
            let res = verifyFileIntegrity(sourceURL: srcURL, destURL: dstURL)
            print(res)
            let res2 = checkFileSize(sourceURL: srcURL, destURL: dstURL)
            print(res2)
            let res3 = checkFileHash(sourceURL: srcURL, destURL: dstURL)
            print(res3)
            let res4 = checkFileContent(sourceURL: srcURL, destURL: dstURL)
            print(res4)
            probeMedia(dstURL: dstURL)
            
            dstVideoFile = dstURL.path
        }
        
        print("文件保护级别:", Bundle.main.object(forInfoDictionaryKey: "NSFileProtectionKey") as? String ?? "未设置")
    }
    
    func verifyFileIntegrity(sourceURL: URL, destURL: URL) -> Bool {
        do {
            let sourceData = try Data(contentsOf: sourceURL)
            let destData = try Data(contentsOf: destURL)
            print("校验成功")
            return sourceData == destData
        } catch {
            print("校验失败: \(error)")
            return false
        }
    }
    
    func checkFileSize(sourceURL: URL, destURL: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            let srcAttr = try fileManager.attributesOfItem(atPath: sourceURL.path)
            let dstAttr = try fileManager.attributesOfItem(atPath: destURL.path)
            let srcSize = srcAttr[.size] as? NSNumber
            let dstSize = dstAttr[.size] as? NSNumber
            print("源文件大小: \(srcSize ?? 0), 目标文件大小: \(dstSize ?? 0)")
            return srcSize == dstSize
        } catch {
            print("获取文件大小失败: \(error)")
            return false
        }
    }

    func fileHash(url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }

    func checkFileHash(sourceURL: URL, destURL: URL) -> Bool {
        guard let srcHash = fileHash(url: sourceURL),
              let dstHash = fileHash(url: destURL) else {
            print("计算哈希失败")
            return false
        }
        print("源文件哈希: \(srcHash)\n目标文件哈希: \(dstHash)")
        return srcHash == dstHash
    }
    
    func checkFileContent(sourceURL: URL, destURL: URL) -> Bool {
        do {
            let srcData = try Data(contentsOf: sourceURL)
            let dstData = try Data(contentsOf: destURL)
            print("内容一致: \(srcData == dstData)")
            return srcData == dstData
        } catch {
            print("读取文件内容失败: \(error)")
            return false
        }
    }
    
    func probeMedia(dstURL: URL) {
        let asset = AVAsset(url: dstURL)
        let tracks = asset.tracks(withMediaType: .video)
        if let track = tracks.first {
            print("width: \(track.naturalSize.width), height: \(track.naturalSize.height), duration: \(asset.duration.seconds)")
        }
    }
}
