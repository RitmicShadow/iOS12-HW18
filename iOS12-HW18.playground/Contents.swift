import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }

        return Chip(chipType: chipType)
    }

    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

class InOutStorage {
    private var chips: [Chip] = []

    func put(_ chip: Chip) {
        chips.append(chip)
    }

    func get() -> Chip? {
        if chips.isEmpty {
            return nil
        } else {
            return chips.removeLast()
        }
    }

    var isEmpty: Bool {
        return chips.isEmpty
    }
}

class GeneratorThread: Thread {
    var storage: InOutStorage

    init(storage: InOutStorage) {
        self.storage = storage
    }

    override func main() {
        print("GeneratorThread Начинает работу")
        for _ in 0..<10 {
            GeneratorThread.sleep(forTimeInterval: 2)
            let newChip = make() 
            print(newChip.chipType)
            storage.put(newChip)
            print("Chip добавлен")
        }
        print("GeneratorThread Закончил выполнение")
        print("WorkerThread Закончил выполнение")
    }

    func make() -> Chip {
        return Chip(chipType: Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1))!)
    }
}

class WorkerThread: Thread {
    var storage: InOutStorage

    init(storage: InOutStorage) {
        self.storage = storage
    }

    override func main() {
        print("WorkerThread Начинает выполнение")
        while !storage.isEmpty {
            if let chip = storage.get() {
                chip.sodering()
            } else {
                WorkerThread.sleep(forTimeInterval: 1)
            }
        }
    }
}

let storage = InOutStorage()
let generatorThread = GeneratorThread(storage: storage)
let workerThread = WorkerThread(storage: storage)

generatorThread.start()
workerThread.start()
