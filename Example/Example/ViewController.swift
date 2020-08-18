import UIKit
import KojiPlayerHelper

class ViewController: UIViewController {
  var tableView: UITableView = UITableView()

  let postIds = ["faf1d37b-f5b0-4cad-8f29-973cb73bf266","615bf061-013f-4cfe-909f-5d9e6bde2e17","2ec6b956-0f45-4582-8ce8-7ed2e5cae11a","74fbfb1f-4aef-4886-a72b-f408f43e7911","04897bad-4e16-4432-ae1a-ce2ceaec6597","86039edf-8941-4a26-8fa9-471780edc19a","cf3b6b9c-689c-4b6b-82e3-6ff4632306c1","eaa668b6-5d44-4271-8518-12ba50c4fc72","4cfac905-eda6-4e02-a073-f2e43ed3a64c","9a3bb34e-22a7-4897-a7af-d60d64370eb3","00142522-0fb0-4fa2-a262-37e19b7cfef0","a78aed1c-47b9-469c-9f32-dcdd0d87f5c1","e5329cfb-1104-4fca-8053-07228caeaa54","6eb2613b-32f3-4782-9b3c-8a335387aa8d","175ecc63-a232-4acf-b3b5-d4ac37dda38d","06691dc0-d9ec-478e-96b3-b82cb9e26b1c","256ba703-71fd-4c3d-9a26-76e8bece1dba","42034b75-115f-403e-a9a8-69ad04588338","5844194f-82c6-4a12-909c-f29ff775c4e8","03250da7-4805-499f-988f-57cc370c3cbb","e8be3cc7-3c82-4ccd-8bad-c9dd68c3cfbf","86960522-eea8-480f-acfd-c48e474f32b4","24b80118-dc97-4516-8db4-f77de5abd7fc","6ac2cd47-a586-4091-be93-b1d9cbc119d5","6562bdca-fb7b-40cd-881f-3043f13a0fcc","2380a614-ae9b-4968-99dd-bce28525077a","b9dae261-2230-4e84-96bd-77f2c54ec7f7","9c0dd731-a809-4cae-a486-be3cd015dd26","f009a3cb-ebf2-43d6-8a5e-d005311dc403","5335fb4a-abb6-407d-bbd7-e5a6cdca3bdd"]

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
    return 10
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
  }

  func playerViewShouldPresentRemixView(_ playerView: KojiPlayerView, remixView: KojiRemixView) {
    self.delegate?.tableShouldPresentRemixView(remixView: remixView)
  }
}

protocol TableProtocol: AnyObject {
  func tableShouldPresentRemixView(remixView: KojiRemixView)
}
