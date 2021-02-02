// Copyright (c) 2020 Bryan Summersett

import Foundation

final class Disposable {
  let dispose: () -> Void

  init(_ dispose: @escaping () -> Void) {
    self.dispose = dispose
  }

  deinit {
    dispose()
  }
}
