import UIKit
import KojiPlayerHelper

class ViewController: UIViewController {
  var tableView: UITableView = UITableView()

  let postIds = [
    "faf1d37b-f5b0-4cad-8f29-973cb73bf266",
    "615bf061-013f-4cfe-909f-5d9e6bde2e17",
    "2ec6b956-0f45-4582-8ce8-7ed2e5cae11a",
    "74fbfb1f-4aef-4886-a72b-f408f43e7911",
    "04897bad-4e16-4432-ae1a-ce2ceaec6597",
    "86039edf-8941-4a26-8fa9-471780edc19a",
    "eaa668b6-5d44-4271-8518-12ba50c4fc72",
    "4cfac905-eda6-4e02-a073-f2e43ed3a64c",
    "faf1d37b-f5b0-4cad-8f29-973cb73bf266",
    "615bf061-013f-4cfe-909f-5d9e6bde2e17",
    "2ec6b956-0f45-4582-8ce8-7ed2e5cae11a",
  ]

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  override var shouldAutorotate: Bool {
    return false
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.allowsSelection = false
    self.tableView.separatorStyle = .none
    self.tableView.frame = self.view.bounds
    self.tableView.register(TableCell.self, forCellReuseIdentifier: "TableCell")
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.view.addSubview(self.tableView)
  }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.postIds.count
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.view.bounds.height / 3 * 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
    cell.delegate = self
    cell.update(post: postIds[indexPath.row])
    return cell
  }
}

extension ViewController: TableProtocol {
  func tableShouldPresentRemixView(remixView: KojiRemixView) {
    remixView.frame = self.view.bounds
    remixView.delegate = self
    self.view.addSubview(remixView)
  }
}

extension ViewController: KojiRemixViewDelegate {
  func remixViewDidClose(_ remixView: KojiRemixView) {
    remixView.removeFromSuperview()
  }

  func remixViewDidCreate(_ remixView: KojiRemixView, urlString: String) {
    print("created!", urlString)
    remixView.removeFromSuperview()
  }
}

class TableCell: UITableViewCell {
  let player: KojiPlayerView = KojiPlayerView()
  weak var delegate: TableProtocol?

  var hasLoaded: Bool = false {
    didSet {
      UIView.animate(withDuration: 0.2) {
        if (self.hasLoaded) {
          self.player.alpha = 1
        } else {
          self.player.alpha = 0
        }
      }
    }
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .black
    self.player.alpha = 0
    self.player.delegate = self
    self.addSubview(self.player)
  }

  func update(post: String) {
    self.hasLoaded = false
    self.player.load(post: post)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.player.frame = self.bounds
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TableCell: KojiPlayerViewDelegate {
  func playerViewDidLoad(_ playerView: KojiPlayerView) {
    self.hasLoaded = true
    self.player.play()
  }

  func playerViewShouldPresentRemixView(_ playerView: KojiPlayerView, remixView: KojiRemixView) {
    self.delegate?.tableShouldPresentRemixView(remixView: remixView)
  }
}

protocol TableProtocol: AnyObject {
  func tableShouldPresentRemixView(remixView: KojiRemixView)
}
