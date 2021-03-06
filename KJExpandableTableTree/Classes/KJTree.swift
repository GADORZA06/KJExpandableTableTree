//
//  KJTreeView.swift
//  Expandable3
//
//  Created by MAC241 on 25/04/17.
//  Copyright © 2017 KiranJasvanee. All rights reserved.
//

import Foundation
import UIKit

open class KJTree {
    
    // Parent to child collection.
    fileprivate var arrayParents: [Parent] = []
    fileprivate var arrayVisibles: [Node] = []
    
    open var insertRowAnimation: UITableView.RowAnimation = .automatic
    open var deleteRowAnimation: UITableView.RowAnimation = .automatic
    open var selectedRowAnimation: UITableView.RowAnimation = .automatic
    
    public init() {
        
    }
    
    public init(Parents: [Parent]) {
        arrayParents = Parents
    }
    
    
    /*
     Parents, childs creation based on indecies -----------------------------------------------------------------------------------------
     */
    public init(indices: [String]) {
        
        for i in 0..<indices.count{
            
            // index to be processed
            let index = indices[i]
            
            // Components
            var components = index.components(separatedBy: ".")
            
            if arrayParents.contains(where: { $0.givenIndex == components.first }) {
                
                // if parent exists
                let position = arrayParents.index(where: { $0.givenIndex == components.first })
                components.removeFirst()
                let parent = self.arrayParents[position!]
                
                // if there are no subchilds, only a child inside parent.
                if components.count == 1 {
                    if !parent.arrayChilds.contains(where: {$0.givenIndex == components.first}) {
                        // create new child
                        let child = Child()
                        child.givenIndex = index
                        parent.arrayChilds.append(child)
                    }
                    //else considers - value already exists, leave this block blank. don't add again.
                }else{
                    // if there are subchilds.
                    let internalIndex = parent.givenIndex+"."+components.first!
                    if parent.arrayChilds.contains(where: {$0.givenIndex == internalIndex}) {
                        let position = parent.arrayChilds.index(where: { $0.givenIndex == internalIndex })
                        var child = parent.arrayChilds[position!]
                        child.givenIndex = internalIndex
                        components.removeFirst()
                        self.addChild(&child, components: &components, index: index)
                        
                    }else{
                        // create new child
                        var child = Child()
                        child.givenIndex = index
                        parent.arrayChilds.append(child)
                        components.removeFirst()
                        self.justAddChildsIn(&child, components: &components)
                    }
                }
            }else{
                // if parent not exists.
                let parent = Parent()
                parent.givenIndex = components.first!
                self.arrayParents.append(parent)
                components.removeFirst()
                
                guard components.count != 0 else {
                    continue
                }
                
                if components.count == 1 {
                    // create new child
                    let child = Child()
                    child.givenIndex = index
                    parent.arrayChilds.append(child)
                }else{
                    // create new child
                    let internalIndex = parent.givenIndex+"."+components.first!
                    var child = Child()
                    child.givenIndex = internalIndex
                    parent.arrayChilds.append(child)
                    components.removeFirst()
                    self.justAddChildsIn(&child, components: &components)
                }
            }
        }
    }
    func addChild(_ inChild: inout Child, components: inout [String], index: String) {
        
        // if there are no subchilds, only a child inside parent.
        if components.count == 1 {
            let internalIndex = inChild.givenIndex+"."+components.first!
            
            if !inChild.arrayChilds.contains(where: {$0.givenIndex == internalIndex}) {
                // create new child
                let child = Child()
                child.givenIndex = internalIndex
                inChild.arrayChilds.append(child)
            }
            //else considers - value already exists, leave this block blank. don't add again.
        }else{
            // if there are subchilds.
            let internalIndex = inChild.givenIndex+"."+components.first!
            if inChild.arrayChilds.contains(where: {$0.givenIndex == internalIndex}) {
                let position = inChild.arrayChilds.index(where: { $0.givenIndex == internalIndex })
                var child = inChild.arrayChilds[position!]
                child.givenIndex = internalIndex
                components.removeFirst()
                self.addChild(&child, components: &components, index: index)
                
            }else{
                // create new child
                var child = Child()
                child.givenIndex = internalIndex
                inChild.arrayChilds.append(child)
                components.removeFirst()
                self.justAddChildsIn(&child, components: &components)
            }
        }
    }
    func justAddChildsIn(_ inChild: inout Child, components: inout [String]) {
        if components.count == 1 {
            // create new child
            let internalIndex = inChild.givenIndex+"."+components.first!
            let child = Child()
            child.givenIndex = internalIndex
            inChild.arrayChilds.append(child)
        }else{
            // create new child
            let internalIndex = inChild.givenIndex+"."+components.first!
            var child = Child()
            child.givenIndex = internalIndex
            inChild.arrayChilds.append(child)
            components.removeFirst()
            self.justAddChildsIn(&child, components: &components)
        }
    }
    /*
     ----------------------------------------------------------------------------------------------------------------
     */
    
    
    
    /*
     Dynamic tree creation ------------------------------------------------------------------------------------------
     */
    public init(parents: NSArray, childrenKey: String, idKey: String? = nil) {
        
        for i in 0..<parents.count {
            
            let parent = parents[i] as? NSDictionary
            
            // if parent is not equal to nil
            guard let parentConfirmed = parent else{
                continue
            }
            
            let parentInstance = Parent()
            if let idKeyConfirmed = idKey {
                if let key = parentConfirmed.object(forKey: idKeyConfirmed) as? String {
                    parentInstance.keyIdentity = key
                }else{
                    if let keyAny = parentConfirmed.object(forKey: idKeyConfirmed) {
                        parentInstance.keyIdentity = "\(keyAny)"
                    }
                }
                
            }
            
            guard let childs = parentConfirmed.object(forKey: childrenKey) as? NSArray, childs.count != 0 else{
                arrayParents.append(parentInstance)
                continue
            }
            
            let arrayOfChilds: [Child] = self.addChildsInTree(childs, childrenKey: childrenKey, idKey: idKey)
            parentInstance.arrayChilds = arrayOfChilds
            
            arrayParents.append(parentInstance)
        }
    }
    func addChildsInTree(_ childs: NSArray, childrenKey: String, idKey: String? = nil) -> [Child]{
        
        var arrayOfChilds: [Child] = []
        for i in 0..<childs.count {
            
            let child = childs[i] as? NSDictionary
            
            // if parent is not equal to nil
            guard let childConfirmed = child else{
                continue
            }
            
            let childInstance = Child()
            if let idKeyConfirmed = idKey {
                if let key = childConfirmed.object(forKey: idKeyConfirmed) as? String {
                    childInstance.keyIdentity = key
                }else{
                    if let keyAny = childConfirmed.object(forKey: idKeyConfirmed) {
                        childInstance.keyIdentity = "\(keyAny)"
                    }
                }
                
            }
            
            guard let childs = child?.object(forKey: childrenKey) as? NSArray, childs.count != 0 else{
                arrayOfChilds.append(childInstance)
                continue
            }
            
            let arrayOfSubChilds = self.addChildsInTree(childs, childrenKey: childrenKey, idKey: idKey)
            childInstance.arrayChilds = arrayOfSubChilds
            
            arrayOfChilds.append(childInstance)
        }
        
        return arrayOfChilds
    }
    /*
     ----------------------------------------------------------------------------------------------------------------
     */
    
    
    
    
    
    /*
     numberOfRowsInSection -----------------------------------------------------------------------------------------
     */
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> NSInteger {
        
        arrayVisibles.removeAll() // remove all objects first
        
        for i in 0..<arrayParents.count {
            
            // get parent instance and check childs of it, if yes go through it?
            let parent = arrayParents[i]
            
            let node = Node(indexParam: "\(i)", idParam: parent.keyIdentity, givenIndexParam: parent.givenIndex, details: parent.details)
            // MARK: Cle - Customized
            // copy arrayChilds to node
            node.arrayChilds = parent.arrayChilds
            node.name = parent.name
            
            arrayVisibles.append(node)
            
            var currentState: State = .none // State decision open, close or none.
            if parent.isVisibility {
                if parent.arrayChilds.count != 0{
                    currentState = .open
                    self.calculateVisibileChilds("\(i)", arrayChilds: parent.arrayChilds)
                }
            }else{
                if parent.arrayChilds.count != 0{
                    currentState = .close
                }
            }
            
            node.state = currentState
        }
        
        return arrayVisibles.count
    }
    func calculateVisibileChilds(_ parentIndex: String, arrayChilds: [Child]){
        
        for i in 0..<arrayChilds.count {
            
            // get child instance
            let child = arrayChilds[i]
            
            let childIndex = parentIndex + ".\(i)"
            
            let node = Node(indexParam: childIndex, idParam: child.keyIdentity, givenIndexParam: child.givenIndex, details: child.details)
            // MARK: Cle - Customized
            // copy arrayChilds to node
            node.arrayChilds = child.arrayChilds
            node.name = child.name
            
            node.index = childIndex
            arrayVisibles.append(node)
            
            var currentState: State = .none // State decision open, close or none.
            if child.isVisibility {
                if child.arrayChilds.count != 0{
                    currentState = .open
                    self.calculateVisibileChilds(childIndex, arrayChilds: child.arrayChilds)
                }
            }else{
                if child.arrayChilds.count != 0{
                    currentState = .close
                }
            }
            
            node.state = currentState
        }
    }
    /*
     ----------------------------------------------------------------------------------------------------------------
     */
    
    
    
    /*
     cellIdentifierUsingTableView -----------------------------------------------------------------------------------
     */
    open func cellIdentifierUsingTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> Node{
        return arrayVisibles[indexPath.row]
    }
    /*
     ----------------------------------------------------------------------------------------------------------------
     */
    
    
    /*
     cellIdentifierUsingTableView -----------------------------------------------------------------------------------
     */
    enum ExpansionOption {
        case expand, shrink, none
    }
    
    open func tableView(_ tableView: UITableView,
                        didSelectRowAtIndexPath indexPath: IndexPath,
                        section: Int,
                        skipTableUIUpdate: Bool = false) -> Node{
        
        let node = arrayVisibles[indexPath.row]
        var cellsToBeUpdated: [NSInteger] = []
        var indices = node.index.components(separatedBy: ".")
        var expansion: ExpansionOption = .none
        
        /*
         
         This works based on . (point) system. if I'm receiving selected index 2 indicates, 3rd row tapped. If I'm receiving 2.0 indicates 0th child in 3rd row tapped. and if I'm receiving 1.2.1 indicates 2nd row -> 3rd child -> 2nd subchild tapped.
         */
        
        if indices.count == 1{
            
            // Why this block?
            // This block will be executed when selected index belongs to parent. Suppose selected index is 2, indicates 3rd parent row selected. For 2.1, 2.0, 2.1.1 or 2.1.4.2 else (child) block will be called.
            
            // get parent instance
            let parent = arrayParents[(indices.first?.integerValue())!]
            
            // if childs are visible, invisible those. and if they are invisible, visible those.
            if parent.isVisibility {
                parent.isVisibility = false
                expansion = .shrink
            }else{
                parent.isVisibility = true
                expansion = .expand
            }
            
            // Go further if there are childs available
            guard parent.arrayChilds.count != 0 else{
                return node
            }
            
            // Expand
            if expansion == .expand {
                // for expansion, append childs of parent, we about to insert this rows in visible list.
                for i in 1...parent.arrayChilds.count{
                    cellsToBeUpdated.append(indexPath.row+i)
                }
                // total no. of rows expanded
                parent.expandedRows = parent.arrayChilds.count
            }else{
                // Shrink
                // for shrink also, append childs of parent, because we about to delete this rows from visible list.
                for i in 1...parent.expandedRows {
                    cellsToBeUpdated.append(indexPath.row+i)
                }
                parent.expandedRows = 0
                self.closeAllVisibleCells(parent.arrayChilds)
            }
        }else{
            // get parent instance and check there are any childs of it, if yes go through it?
            let parent = arrayParents[(indices.first?.integerValue())!]
            indices.removeFirst()
            
            // openNoOfChilds holds no of childs open inside parent. which ultimatey added/removed (based on expansion and shrinking) to expandableRows property of parent. Same will be done at childs to childs.
            let openNoOfChilds = self.visibleChilds(parent.arrayChilds, indices: &indices, index: indexPath.row, cellsUpdatedHolder: &cellsToBeUpdated, expansionOption: &expansion)
            if expansion == .expand {
                parent.expandedRows += openNoOfChilds
            }else{
                parent.expandedRows -= openNoOfChilds
            }
        }
        
        // get indexpath about to insert/remove cells
        var indexpathsInserted: [IndexPath] = []
        // for effects of plus, minus or none based on expand, shrink.
        var updateStateOfRow: NSInteger = -1
        for row in cellsToBeUpdated {
            // access previous cell to be updated with effects of plus, minus or none.
            if updateStateOfRow == -1{
                updateStateOfRow = row-1
            }
            let indexpath: IndexPath = IndexPath(row: row, section: section)
            indexpathsInserted.append(indexpath)
        }
        
        if !skipTableUIUpdate {
            if expansion == .expand {
                // Insert rows
                tableView.insertRows(at: indexpathsInserted, with: insertRowAnimation)
            } else{
                // remove rows
                tableView.deleteRows(at: indexpathsInserted, with: deleteRowAnimation)
            }
        }
        // indicates there is some expansion or shrinking by updating previous cell with plus, minus or none.
//        if updateStateOfRow != -1 {
//            let indexpath: IndexPath = IndexPath(row: updateStateOfRow, section: 0)
//            tableView.reloadRows(at: [indexpath], with: selectedRowAnimation)
//        }
        
        
        return node
    }
    func visibleChilds(_ childs: [Child], indices: inout [String], index: NSInteger, cellsUpdatedHolder  cellsToBeUpdated: inout [NSInteger], expansionOption  expansion:  inout ExpansionOption) -> NSInteger {
        
        if indices.count == 1{
            
            // Why this block?
            // This block will be executed when selected index belongs to any child. Suppose selected index is 2.1, indicates 2nd child row of 3rd parent. Here, we won't get parent index, we will get index of child -> subChilds -> further.
            // In above given example, we will get 1 from 2.1, means 2nd child, which will be processed as below.
            // Or if you want to consider a new example, suppose 1.2.1, we will receive 2.1 in this function, whereas else block will be called to perform recursion by removing 2.
            
            let child = childs[(indices.first?.integerValue())!]
            if child.isVisibility {
                child.isVisibility = false
                expansion = .shrink
            }else{
                child.isVisibility = true
                expansion = .expand
            }
            
            // Go further if there are childs available
            guard child.arrayChilds.count != 0 else{
                return 0
            }
            
            // Expand
            if expansion == .expand {
                // for expansion, append subChilds of child, we about to insert this rows in visible list.
                for i in 1...child.arrayChilds.count{
                    cellsToBeUpdated.append(index+i)
                }
                // total no. of rows expanded
                child.expandedRows = child.arrayChilds.count
                return child.arrayChilds.count
            }else{
                // Shrink
                
                // for shrink also, append subChilds of child, because we about to delete this rows from visible list.
                for i in 1...child.expandedRows {
                    cellsToBeUpdated.append(index+i)
                }
                
                let expandableRows = child.expandedRows
                child.expandedRows = 0
                self.closeAllVisibleCells(child.arrayChilds)  // Close all visible childs of shrinking child/parent.
                return expandableRows
                // Why expandable rows should be returned, because you expanded up to 4th level, and you pressed 2nd level to close 3rd and 4th both. So sending 2nd level childs will only contain 3rd level cells not 4th level, whereas expandable rows will contains all the sublevels.
            }
        }else{
            let child = childs[(indices.first?.integerValue())!]
            indices.removeFirst()
            let openNoOfChilds = self.visibleChilds(child.arrayChilds, indices: &indices, index: index, cellsUpdatedHolder: &cellsToBeUpdated, expansionOption: &expansion)
            if expansion == .expand {
                child.expandedRows += openNoOfChilds
            }else{
                child.expandedRows -= openNoOfChilds
            }
            return openNoOfChilds
        }
    }
    func closeAllVisibleCells(_ childs: [Child]) {
        for child in childs {
            child.isVisibility = false
            child.expandedRows = 0
            
            // Indicates there are childs
            if child.arrayChilds.count != 0{
                self.closeAllVisibleCells(child.arrayChilds)
            }
        }
    }
    
    /*
     ----------------------------------------------------------------------------------------------------------------
     */
    
    
}

extension String {
    func integerValue() -> NSInteger {
        return (self as NSString).integerValue
    }
}

public enum State{
    case open, close, none
}


open class Node {
    
    // MARK: Cle - Customized
    // changed to public private(set) from private - so that user can read arrayChilds
    open fileprivate(set) var arrayChilds: [Child] = []
    // Cle -
    open var name: String = ""
    
    // identity key
    open var keyIdentity: String = ""
    
    // Private instances
    fileprivate var isVisibility = false    // This will visible or invisible no of rows based on selection.
    fileprivate var expandedRows = 0        // This will hold a total of visible rows under it.
    
    // Indecies helper property
    open var index = "-1"
    
    // public instances
    open var state: State = .none
    open var id: String = ""
    open var givenIndex: String = ""
    open var details: [String: Any]?
    
    public init() {
        
    }
    public init(indexParam: String,
                idParam: String,
                givenIndexParam: String,
                details: [String: Any]? = nil) {
        index = indexParam
        id = idParam
        keyIdentity = idParam
        givenIndex = givenIndexParam
        self.details = details
    }
}

open class Parent: Node {
    
    public override init() {
        super.init()
    }
    public init(childs: () -> [Child]) {
        super.init()
        arrayChilds = childs()
        // print(arrayChilds)
    }
    public init(key: String, details: [String: Any]? = nil) {
        super.init()
        keyIdentity = key
        self.details = details
    }
    public init(key: String , childs: () -> [Child], details: [String: Any]? = nil) {
        super.init()
        keyIdentity = key
        arrayChilds = childs()
        self.details = details
        // print(arrayChilds)
    }
}
open class Child: Node{
    
    public override init() {
        super.init()
    }
    public init(subChilds: () -> [Child]) {
        super.init()
        arrayChilds = subChilds()
        // print(arrayChilds)
    }
    public init(key: String) {
        super.init()
        keyIdentity = key
    }
    public init(key: String, subChilds: () -> [Child], details: [String: Any]? = nil) {
        super.init()
        keyIdentity = key
        arrayChilds = subChilds()
        self.details = details
        // print(arrayChilds)
    }
}










