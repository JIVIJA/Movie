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
    
    let disposeBag = DisposeBag()
    var managedObjectContext: NSManagedObjectContext!
    let cellPercentWidth: CGFloat = 0.70
    let cellPercentHeight: CGFloat = 0.75
    var movieCollectionViewFlowLayout: MovieCollectionViewFlowLayout!
    
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK:- General Methods
    private func configure() {
        
        movieCollectionViewFlowLayout = (collVHome.collectionViewLayout as! MovieCollectionViewFlowLayout)
        collVHome.decelerationRate = UIScrollView.DecelerationRate.fast
        movieCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * cellPercentWidth,
            height: view.bounds.height * cellPercentHeight * cellPercentHeight
        )
        movieCollectionViewFlowLayout.minimumLineSpacing = 15
        
        HomeViewModel.shared.loadMovieLists()
        addObserverAndSubscriber()
    }
    
    private func addObserverAndSubscriber() {
        
        let animatedDataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String,MovieList>>(configureCell: { dateSource, collectionView, indexPath, movieDetails in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as? HomeCVCell else{
                return UICollectionViewCell()
            }
            self.activityIndicator.stopAnimating()
            cell.configureCell(movieList: movieDetails)
            return cell
        })
        
        //...Creates and executes a fetch request and returns the fetched objects as an Observable array of Persistable.
        
        let CSharedApplication = UIApplication.shared
        let CAppdelegate = CSharedApplication.delegate as? AppDelegate
        
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
        
    }

}
