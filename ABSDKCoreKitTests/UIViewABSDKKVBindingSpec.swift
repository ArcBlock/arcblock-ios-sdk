//
//  UIViewABSDKKVBindingSpec.swift
//  ABSDKCoreKitTests
//
//  Created by Jonathan Lu on 10/5/2018.
//

import Quick
import Nimble

class UIViewABSDKKVBindingSpec: QuickSpec {
    override func spec() {
        describe("UIView KV Binding") {
            var label: UILabel?
            var imageView: UIImageViewMock?
            var button: UIButton?
            var view: UIView?
            let viewModel = ["name": "John Appleseed", "avatar": "http://example.com", "action": "Message"]
            let mockImage = UIImage.init()

            beforeSuite {
                label = UILabel.init()
                label?.bind("text", objectKey: "name")
                imageView = UIImageViewMock.init(mockURL: viewModel["avatar"], image: mockImage)
                imageView?.bind("imageUrl", objectKey: "avatar")
                button = UIButton.init()
                button?.bind("title", objectKey: "action")
                view = UIView.init()
                view?.addSubview(label!)
                view?.addSubview(imageView!)
                view?.addSubview(button!)
            }

            beforeEach {
                view?.update(with: viewModel)
            }

            it("label text is bond", closure: {
                expect(label?.text).to(equal(viewModel["name"]))
            })

            it("button title is bond", closure: {
                expect(button?.title(for: UIControlState.normal)).to(equal(viewModel["action"]))
            })

            it("image view is bond", closure: {
                expect(imageView?.image).to(equal(mockImage))
            })
        }
    }
}
