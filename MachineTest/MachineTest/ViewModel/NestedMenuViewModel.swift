//
//  NestedMenuViewModel.swift
//  MachineTest
//
//  Created by SD on 08/01/21.
//

import Foundation


protocol Copying {
    init(original: Self)
}

class NestedMenuViewModel {
    var arrMainNestedMenu = [NestedMenuCellViewModel]()
    var arrNestedMenu = [NestedMenuCellViewModel]()
    var lastExpandedHierarchyPos = -1
    
    //MARK:- API call
    func ferchRemoteData(completion: @escaping() -> Void)  {
        Loader.shared.showLoader()
        NetworkRequestManager.shared.requestWithGet(endPoint: "",query: "", request: UnknownRequest(), header: NetworkHeaders(), response: NestedMenu.self) { (response,message,isNewToken) in
            DispatchQueue.main.async {
                Loader.shared.hideLoader()
                if let resp = response {
                    if resp.status ?? false {
                        if let objectiveArr = resp.data?.first?.planning?.objective,objectiveArr.count > 0 {
                            for (index,item) in objectiveArr.enumerated() {
                                self.arrNestedMenu.append(NestedMenuCellViewModel(objective: item,rootIndex: index))
                            }
                            completion()
                        } else {
                            self.arrNestedMenu.removeAll()
                            completion()
                        }
                    } else {
                        self.arrNestedMenu.removeAll()
                        completion()
                    }
                    debugPrint("Message:-",message)
                } else {
                    self.arrNestedMenu.removeAll()
                    completion()
                    debugPrint("response:-",message)
                }
            }
        }
    }
    
    /// get particular row object using subscript
    subscript(indexPath: IndexPath) -> NestedMenuCellViewModel {
        return self.arrNestedMenu[indexPath.row]
    }
    ///Row count
    func count() -> Int {
        return self.arrNestedMenu.count
    }
    
    //MARK:- Prepare Menu Selection -
    /// Toggle Menu
    func toggleMenu(indexPath: IndexPath)  {
        guard self.arrNestedMenu.count > indexPath.row else {
            return
        }
        
        //Appending data
        func appendInnerRows(at index: Int)  {
            if self.arrNestedMenu[index].child.count > 0 {
                self.arrNestedMenu[index].isExpanded = true
                _ = self.arrNestedMenu.map({ (obj) in
                    obj.lastExpandedNode = false
                })
                self.arrNestedMenu[index].lastExpandedNode = true
                self.lastExpandedHierarchyPos = self.arrNestedMenu[index].hierarchyPosition
                self.append(to: index)
            }
        }
        func removeOldNodes() {
            var position = 0
            for item in self.arrNestedMenu {
                if item.currentlyExpandedNode {
                    position = item.hierarchyPosition
                    break
                }
            }
            self.arrNestedMenu.removeAll { (objToDel) in
                return objToDel.hierarchyPosition > position
            }
        }
        func getNewIndexAfterDelete() -> Int {
            for (index,item) in self.arrNestedMenu.enumerated() {
                if item.currentlyExpandedNode {
                    return index
                }
            }
            return 0
        }
        
        let currentHierrachyPos = self.arrNestedMenu[indexPath.row].hierarchyPosition
        if currentHierrachyPos > 0 {
            if self.arrNestedMenu[indexPath.row].child.count > 0 {
                if currentHierrachyPos <= self.lastExpandedHierarchyPos {
                    ///Marking curently expanded row
                    _ = self.arrNestedMenu.map({ (obj) in
                        obj.currentlyExpandedNode = false
                    })
                    self.arrNestedMenu[indexPath.row].currentlyExpandedNode = true
                    
                    removeOldNodes()
                    let newIndex = getNewIndexAfterDelete()
                    appendInnerRows(at: newIndex)
                    return
                }
            }
        } else {
            //different root row
            if self.arrNestedMenu[indexPath.row].isExpanded {
                /// Already expanded row
                self.arrNestedMenu.removeAll { (objToDel) in
                    return objToDel.hierarchyPosition > currentHierrachyPos
                }
                self.arrNestedMenu[indexPath.row].isExpanded = false
                return
            } else {
                //New Root row
                _ = self.arrNestedMenu.map({ (obj) in
                    obj.isExpanded = false
                })
                ///Marking curently expanded row
                _ = self.arrNestedMenu.map({ (obj) in
                    obj.currentlyExpandedNode = false
                })
                self.arrNestedMenu[indexPath.row].currentlyExpandedNode = true
                
                removeOldNodes()
                let newIndex = getNewIndexAfterDelete()
                appendInnerRows(at: newIndex)
                return
            }
            
        }
        
        
        appendInnerRows(at: indexPath.row)
        return
    }
    
    func append(to rowPosition: Int)  {
        let tempArr = self.arrNestedMenu[rowPosition].child
        for (index,item) in tempArr.enumerated() {
            self.arrNestedMenu.insert(item, at: (rowPosition + (index + 1)))
        }
    }
}

class NestedMenuCellViewModel: Copying {
    var name: String = ""
    var isExpanded: Bool = false
    var hierarchyPosition: Int = 0
    var child: [NestedMenuCellViewModel] = []
    var rootIndex: Int = 0
    var lastExpandedNode: Bool = false
    var currentlyExpandedNode: Bool = false
    
    required init(original: NestedMenuCellViewModel) {
        name = original.name
        isExpanded = original.isExpanded
        child = original.child
        hierarchyPosition = original.hierarchyPosition
        rootIndex = original.rootIndex
        lastExpandedNode = original.lastExpandedNode
        currentlyExpandedNode = original.currentlyExpandedNode
    }
    
    init(objective: Objective? = nil,keyResult: KeyResult? = nil,rootIndex: Int,position: Int = 0) {
        if let objective = objective {
            self.rootIndex = rootIndex
            self.name = objective.contentObj ?? ""
            self.hierarchyPosition = position
            self.child = (objective.keyResult ?? []).map({ (keyObj) in
                return NestedMenuCellViewModel(keyResult: keyObj,rootIndex: rootIndex,position: self.hierarchyPosition + 1)
            })
        }
        if let keyResult = keyResult {
            self.rootIndex = rootIndex
            self.name = keyResult.keyResult ?? ""
            self.hierarchyPosition = position
            self.child = []
        }
    }
}
