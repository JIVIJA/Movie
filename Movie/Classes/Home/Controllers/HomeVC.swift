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
import CoreData
import RxCoreData
import RxDataSources

class HomeVC: ParentVC {
    
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var lblMovieName: UILabel!
    @IBOutlet fileprivate weak var lblMovieType: UILabel!
    @IBOutlet fileprivate weak var collVHome: UICollectionView!{
        didSet {
            collVHome.register(UINib(nibName: "HomeCVCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCell")
        }
    }
    
    private var autoScrollTimer: Timer?
    private var needToStartTimer:Variable<Bool> = Variable(false)
    private let CELLWIDTH =  CScreenWidth * 70/100
    private let  TRANSFORM_CELL_VALUE = CGAffineTransform(scaleX: 0.9, y: 0.9)
    private let  TRANSFORM_CELL_VALUE_FOR_UPPER = CGAffineTransform(scaleX: 0.9, y: 0.9)
    private let ANIMATION_SPEED = 0.3
    private var selectedIndexPath = IndexPath(row: 0, section: 0)
    private var nextIndex:Int? {
         return (selectedIndexPath.row + 1 ) % HomeViewModel.shared.arrMovies.value.count
    }
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initializeTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resetTimer()
    }
    
    //MARK:- General Methods
    private func configure() {
        // set delegate to access flowlayout methods
        collVHome.rx.setDelegate(self).disposed(by: disposeBag)
        self.activityIndicator.startAnimating()
        HomeViewModel.shared.loadMovieLists()
        addObserverAndSubscriber()
    }
    
    private func addObserverAndSubscriber() {
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieLists")
        
        do {
            if let arrMovieLists = try CAppdelegate?.persistentContainer.viewContext.fetch(fetchRequest) as? [MovieLists]{
                HomeViewModel.shared.arrMovies.value = arrMovieLists
            }
            
        } catch {
            print(error)
        }
        
        let animatedDataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String,MovieList>>(configureCell: { dateSource, collectionView, indexPath, movieLists in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as? HomeCVCell else{
                return UICollectionViewCell()
            }
            self.activityIndicator.stopAnimating()
            cell.transform = self.selectedIndexPath == indexPath ? CGAffineTransform.identity : self.TRANSFORM_CELL_VALUE
            cell.cnBtnBookHeight.constant = self.selectedIndexPath == indexPath ? 40.0 : 0
            cell.configureCell(movieList: movieLists)
            return cell
        })
        
        //...Creates and executes a fetch request and returns the fetched objects as an Observable array of Persistable.
        
        CAppdelegate?.persistentContainer.viewContext.rx.entities(MovieList.self, sortDescriptors: [NSSortDescriptor(key: "id", ascending: false)]).map { movieList in
            [AnimatableSectionModel(model: "", items: movieList)]
            }.bind(to: collVHome.rx.items(dataSource: animatedDataSource)).disposed(by: disposeBag)
        
        
        //...Observing UITableView row selection.
        Observable.zip(collVHome.rx.itemSelected, collVHome.rx.modelSelected(MovieList.self)).bind { indexPath, movieModel in
            //            if let movieDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailsVC") as? MovieDetailsVC {
            //                movieDetailVC.movieID = movieModel.id
            //                self.navigationController?.pushViewController(movieDetailVC, animated: true)
            //            }
            }.disposed(by: disposeBag)
        
        
        //.. Keep Observing for scrollView's Begin Dragging Updates for stoping the auto-scroll.
        collVHome.rx.willBeginDragging.subscribe(onNext: { (_) in
            self.needToStartTimer.value = false
        }, onError: nil, onCompleted: nil).disposed(by: disposeBag)
        
        
        //.. Keep Observing for scrollView's End Decelerating Updates for reset the auto-scroll & Showing Movie-Details.
        collVHome.rx.didEndDecelerating.subscribe(onNext: { (_) in
            self.needToStartTimer.value = true
        }, onError: nil, onCompleted: nil).disposed(by: disposeBag)
        
    }
    
    //MARK:- SetupTimer for Auto update screen
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
    
    @objc fileprivate func autoScroll() {
        
        if let nextIndex = nextIndex {
             setScaleForItem(index: nextIndex)
            //showMovieDetails(index: nextIndex)
        }
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:(self.view.frame.size.width*CELLWIDTH)/CScreenWidth, height: collVHome.frame.size.height - 40)
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

        selectedIndexPath = IndexPath(item: index, section: 0)
        collVHome.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        
        if index == 0{
            
            if let cell : HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index, section: 0)) as? HomeCVCell{
                UIView.animate(withDuration: ANIMATION_SPEED) {
                    cell.transform = CGAffineTransform.identity;
                    cell.cnBtnBookHeight.constant = 40.0
                }
            }
            
            if let cell : HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index+1, section: 0)) as? HomeCVCell{
                UIView.animate(withDuration: ANIMATION_SPEED) {
                    cell.transform = self.TRANSFORM_CELL_VALUE;
                    cell.cnBtnBookHeight.constant = 0
                }
            }
        }else{
            if let cell : HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index, section: 0)) as? HomeCVCell{
                UIView.animate(withDuration: ANIMATION_SPEED) {
                    cell.transform = CGAffineTransform.identity;
                    cell.cnBtnBookHeight.constant = 40.0
                }
            }
            
            if let cell : HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index-1, section: 0)) as? HomeCVCell{
                UIView.animate(withDuration: ANIMATION_SPEED) {
                    cell.transform = self.TRANSFORM_CELL_VALUE;
                    cell.cnBtnBookHeight.constant = 0
                }
            }
            
            if let cell : HomeCVCell  = collVHome.cellForItem(at: IndexPath(item: index+1, section: 0)) as? HomeCVCell{
                UIView.animate(withDuration: ANIMATION_SPEED) {
                    cell.transform = self.TRANSFORM_CELL_VALUE;
                    cell.cnBtnBookHeight.constant = 0
                }
            }
        }
    }
    }
