//
//  HomeVC.swift
//  Movie
//
//  Created by mac-00017 on 22/01/19.
//  Copyright © 2019 mac-0007. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxCoreData
import RxDataSources

class HomeVC: ParentVC {
    
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var lblMovieName: UILabel!
    @IBOutlet fileprivate weak var lblMovieType: UILabel!
    @IBOutlet fileprivate weak var collVHome: UICollectionView!{
        didSet {
            collVHome.register(UINib(nibName: "HomeCVCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCVCell")
        }
    }
    
    private var autoScrollTimer: Timer?
    private let CELLWIDTH =  CScreenWidth * 60/100
    private let TRANSFORM_CELL_VALUE = CGAffineTransform(scaleX: 0.9, y: 0.9)
    private let TRANSFORM_CELL_VALUE_FOR_UPPER = CGAffineTransform(scaleX: 0.9, y: 0.9)
    private let ANIMATION_SPEED = 0.3
    private var selectedIndexPath = IndexPath(row: 0, section: 0)
    private var nextIndex:Int? {
        if HomeViewModel.shared.arrMovies.value.count > 0 {
            return (selectedIndexPath.row + 1 ) % (HomeViewModel.shared.arrMovies.value.count )
        }
        return nil
    }
    
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    
    //MARK:- General Methods
    private func configure() {
        title = "Movie"
        
        //...
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(btnRightBarSearchClicked(_:)))
        
        //...Load Data
        HomeViewModel.shared.loadMovies()
        HomeViewModel.shared.getAllLocalMovieData()
        
        //... Set delegate to access flowlayout methods
        collVHome.rx.setDelegate(self).disposed(by: disposeBag)
        
        //...
        addObserverAndSubscriber()
    }
    
    private func addObserverAndSubscriber() {
        
        let animatedDataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, MovieModel>>(configureCell: { dateSource, collectionView, indexPath, movieModel in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCVCell", for: indexPath) as? HomeCVCell else{
                return UICollectionViewCell()
            }
            
            self.initializeTimer()
            self.activityIndicator.stopAnimating()
            self.selectedIndexPath == indexPath ? self.showMovieDetail(index: indexPath.row) : nil
            
            cell.transform = self.selectedIndexPath == indexPath ? CGAffineTransform.identity : self.TRANSFORM_CELL_VALUE
            cell.cnBtnBookHeight.constant = self.selectedIndexPath == indexPath ? 40.0 : 0
            cell.configureCell(movieModel: movieModel)
            
            return cell
        })
        
        
        HomeViewModel.shared.needToStartTimer.asObservable().subscribe(onNext: { (needToStartTimer) in
            needToStartTimer ? self.initializeTimer() : self.resetTimer()
        }).disposed(by: disposeBag)
        
        //...Creates and executes a fetch request and returns the fetched objects as an Observable array of Persistable.
        CAppdelegate?.persistentContainer.viewContext.rx.entities(MovieModel.self, sortDescriptors: [NSSortDescriptor(key: "id", ascending: false)]).map { movieList in
            [AnimatableSectionModel(model: "", items: movieList)]
            }.bind(to: collVHome.rx.items(dataSource: animatedDataSource)).disposed(by: disposeBag)
        
        
        
        //...Keep Observing for scrollView's Begin Dragging Updates for stoping the auto-scroll.
        collVHome.rx.willBeginDragging.subscribe(onNext: { (_) in
            HomeViewModel.shared.needToStartTimer.value = false
        }, onError: nil, onCompleted: nil).disposed(by: disposeBag)
        
        
        
        //...Keep Observing for scrollView's End Decelerating Updates for reset the auto-scroll & Showing Movie-Details.
        collVHome.rx.didEndDecelerating.subscribe(onNext: { (_) in
            HomeViewModel.shared.needToStartTimer.value = true
        }, onError: nil, onCompleted: nil).disposed(by: disposeBag)
        
    }
    
    fileprivate func showMovieDetail(index:Int) {
        let movieTupple = HomeViewModel.shared.showMovieDetail(index: index)
        lblMovieName.text = movieTupple.strName
        lblMovieType.text = movieTupple.strType
    }
    
}

//MARK:-
//MARK:- Setup Timer for Auto update screen
extension HomeVC {
    
    private func initializeTimer() {
        if autoScrollTimer == nil {
            self.autoScrollTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
        }
    }
    
    private func resetTimer() {
        if let autoScrollTimer = self.autoScrollTimer , autoScrollTimer.isValid {
            self.autoScrollTimer?.invalidate()
            self.autoScrollTimer = nil
        }
    }
    
    @objc private func autoScroll() {
        if let nextIndex = nextIndex {
            setScaleForItem(index: nextIndex)
        }
    }
}

//MARK:-
//MARK:- UICollectionViewDelegateFlowLayout
extension HomeVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:(self.view.frame.size.width*CELLWIDTH)/CScreenWidth, height: collVHome.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: (self.view.frame.size.width - ((self.view.frame.size.width * CELLWIDTH)/CScreenWidth))/2, bottom: 0, right: (self.view.frame.size.width - ((self.view.frame.size.width * CELLWIDTH)/CScreenWidth))/2);
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = CELLWIDTH;
        let currentOffset = Float(scrollView.contentOffset.x)
        let targetOffset = Float(targetContentOffset.pointee.x)
        var newTargetOffset = Float(0)
        
        if targetOffset > currentOffset {
            newTargetOffset = ceilf(currentOffset / Float(pageWidth)) * Float(pageWidth)
        } else {
            newTargetOffset = floorf(currentOffset / Float(pageWidth)) * Float(pageWidth)
        }
        
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if newTargetOffset > Float(scrollView.contentSize.width) {
            newTargetOffset = Float(scrollView.contentSize.width)
        }
        
        _ = Float(targetContentOffset.pointee.x) == currentOffset
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: 0), animated: true)
        let index : Int = Int(newTargetOffset / Float(pageWidth))
        self.setScaleForItem(index: index)
    }
    
    private func setScaleForItem(index : Int) {
        if index < HomeViewModel.shared.arrMovies.value.count {
            
            selectedIndexPath = IndexPath(item: index, section: 0)
            collVHome.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
            showMovieDetail(index: index)
            
            if index == 0 {
                
                if let cell: HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index, section: 0)) as? HomeCVCell {
                    UIView.animate(withDuration: ANIMATION_SPEED) {
                        cell.transform = CGAffineTransform.identity
                        cell.cnBtnBookHeight.constant = 40.0
                    }
                }
                
                if let cell: HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index+1, section: 0)) as? HomeCVCell {
                    UIView.animate(withDuration: ANIMATION_SPEED) {
                        cell.transform = self.TRANSFORM_CELL_VALUE;
                        cell.cnBtnBookHeight.constant = 0
                    }
                }
            } else {
                if let cell: HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index, section: 0)) as? HomeCVCell{
                    UIView.animate(withDuration: ANIMATION_SPEED) {
                        cell.transform = CGAffineTransform.identity;
                        cell.cnBtnBookHeight.constant = 40.0
                    }
                }
                
                if let cell: HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index-1, section: 0)) as? HomeCVCell{
                    UIView.animate(withDuration: ANIMATION_SPEED) {
                        cell.transform = self.TRANSFORM_CELL_VALUE;
                        cell.cnBtnBookHeight.constant = 0
                    }
                }
                
                if let cell: HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index+1, section: 0)) as? HomeCVCell{
                    UIView.animate(withDuration: ANIMATION_SPEED) {
                        cell.transform = self.TRANSFORM_CELL_VALUE;
                        cell.cnBtnBookHeight.constant = 0
                    }
                }
            }
        }
    }
}

//MARK:- Action Events
extension HomeVC {
    
    @objc func btnRightBarSearchClicked(_ barButtonItem: UIBarButtonItem) {
        let presentingVC = ParentNVC(rootViewController: SearchVC(nibName: "SearchVC", bundle: Bundle.main))
        present(presentingVC, animated: true, completion: nil)
    }
    
}
