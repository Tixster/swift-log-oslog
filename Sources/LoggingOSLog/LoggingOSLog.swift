import Foundation
import Logging
import os

public struct LoggingOSLog: LogHandler {
    public var logLevel: Logging.Logger.Level = .info
    public let label: String
    private let osLogger: os.Logger

    public init(label: String, category: String) {
        self.label = label
        self.osLogger = os.Logger(subsystem: label, category: category)
    }

    public init(label: String, log: os.Logger) {
        self.label = label
        self.osLogger = log
    }
    
    public func log(level: Logging.Logger.Level, message: Logging.Logger.Message, metadata: Logging.Logger.Metadata?, file: String, function: String, line: UInt) {
        var combinedPrettyMetadata = self.prettyMetadata
        if let metadataOverride = metadata, !metadataOverride.isEmpty {
            combinedPrettyMetadata = self.prettify(
                self.metadata.merging(metadataOverride) {
                    return $1
                }
            )
        }
        
        var formedMessage = message.description
        if combinedPrettyMetadata != nil {
            formedMessage += " -- " + combinedPrettyMetadata!
        }

        switch level {
        case .trace:
            osLogger.trace("\(formedMessage)")
        case .debug:
            osLogger.debug("\(formedMessage)")
        case .info:
            osLogger.info("\(formedMessage)")
        case .notice:
            osLogger.notice("\(formedMessage)")
        case .warning:
            osLogger.warning("\(formedMessage)")
        case .error:
            osLogger.error("\(formedMessage)")
        case .critical:
            osLogger.critical("\(formedMessage)")
        }

    }
    
    private var prettyMetadata: String?
    public var metadata = Logging.Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }
    
    /// Add, remove, or change the logging metadata.
    /// - parameters:
    ///    - metadataKey: the key for the metadata item.
    public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
    
    private func prettify(_ metadata: Logging.Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        }
        return metadata.map {
            "\($0)=\($1)"
        }.joined(separator: " ")
    }
}
