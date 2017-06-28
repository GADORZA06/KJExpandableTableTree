//
//  KJTreeView.swift
//  Expandable3
//
//  Created by MAC241 on 25/04/17.
//  Copyright © 2017 KiranJasvanee. All rights reserved.
//

import Foundation
import UIKit

public class KJTree{
    
    // Parent to child collection.
    private var arrayParents: [Parent] = []
    private var arrayVisibles: [Node] = []
    
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
            var components = index.componentsSeparatedByString(".")
            
            if arrayParents.contains({ $0.givenIndex == components.first }) {
                
                // if parent exists
                let position = arrayParents.indexOf({ $0.givenIndex == components.first })
                components.removeFirst()
                let parent = self.arrayParents[position!]
                
                // if there are no subchilds, only a child inside parent.
                if components.count == 1 {
                    if !parent.arrayChilds.contains({$0.givenIndex == components.first}) {
                        // create new child
                        let child = Child()
                        child.givenIndex = index
                        parent.arrayChilds.append(child)
                    }
                    //else considers - value already exists, leave this block blank. don't add again.
                }else{
                    // if there are subchilds.
                    let internalIndex = parent.givenIndex+"."+components.first!
                    if parent.arrayChilds.contains({$0.givenIndex == internalIndex}) {
                        let position = parent.arrayChilds.indexOf({ $0.givenIndex == internalIndex })
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
    func addChild(inout inChild: Child, inout components: [String], index: String) {
        
        // if there are no subchilds, only a child inside parent.
        if components.count == 1 {
            let internalIndex = inChild.givenIndex+"."+components.first!
            
            if !inChild.arrayChilds.contains({$0.givenIndex == internalIndex}) {
                // create new child
                let child = Child()
                child.givenIndex = internalIndex
                inChild.arrayChilds.append(child)
            }
            //else considers - value already exists, leave this block blank. don't add again.
        }else{
            // if there are subchilds.
            let internalIndex = inChild.givenIndex+"."+components.first!
            if inChild.arrayChilds.contains({$0.givenIndex == internalIndex}) {
                let position = inChild.arrayChilds.indexOf({ $0.givenIndex == internalIndex })
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
    func justAddChildsIn(inout inChild: Child, inout components: [String]) {
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
                if let key = parentConfirmed.objectForKey(idKeyConfirmed) as? String {
                    parentInstance.keyIdentity = key
                }else{
                    if let keyAny = parentConfirmed.objectForKey(idKeyConfirmed) {
                        parentInstance.keyIdentity = "\(keyAny)"
                    }
                }
                
            }
            
            guard let childs = parentConfirmed.objectForKey(childrenKey) as? NSArray where childs.count != 0 else{
                arrayParents.append(parentInstance)
                continue
            }
            
            let arrayOfChilds: [Child] = self.addChildsInTree(childs, childrenKey: childrenKey, idKey: idKey)
            parentInstance.arrayChilds = arrayOfChilds
            
            arrayParents.append(parentInstance)
        }
    }
    func addChildsInTree(childs: NSArray, childrenKey: String, idKey: String? = nil) -> [Child]{
        
        var arrayOfChilds: [Child] = []
        for i in 0..<childs.count {
            
            let child = childs[i] as? NSDictionary
            
            // if parent is not equal to nil
            guard let childConfirmed = child else{
                continue
            }
            
            let childInstance = Child()
            if let idKeyConfirmed = idKey {
                if let key = childConfirmed.objectForKey(idKeyConfirmed) as? String {
                    childInstance.keyIdentity = key
                }else{
                    if let keyAny = childConfirmed.objectForKey(idKeyConfirmed) {
                        childInstance.keyIdentity = "\(keyAny)"
                    }
                }
                
            }
            
            guard let childs = child?.objectForKey(childrenKey) as? NSArray where childs.count != 0 else{
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
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> NSInteger {
        
        arrayVisibles.removeAll() // remove all objects first
        
        for i in 0..<arrayParents.count {
            
            // get parent instance and check childs of it, if yes go through it?
            let parent = arrayParents[i]
            
            let node = Node(indexParam: "\(i)", idParam: parent.keyIdentity, givenIndexParam: parent.givenIndex)
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
    func calculateVisibileChilds(parentIndex: String, arrayChilds: [Child]){
        
        for i in 0..<arrayChilds.count {
            
            // get child instance
            let child = arrayChilds[i]
            
            let childIndex = parentIndex + ".\(i)"
            
            let node = Node(indexParam: childIndex, idParam: child.keyIdentity, givenIndexParam: child.givenIndex)
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
    public func cellIdentifierUsingTableView(tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> Node{
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
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Node{
        
        let node = arrayVisibles[indexPath.row]
        var cellsToBeUpdated: [NSInteger] = []
        var indices = node.index.componentsSeparatedByString(".")
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
        var indexpathsInserted: [NSIndexPath] = []
        // for effects of plus, minus or none based on expand, shrink.
        var updateStateOfRow: NSInteger = -1
        for row in cellsToBeUpdated {
            // access previous cell to be updated with effects of plus, minus or none.
            if updateStateOfRow == -1{
                updateStateOfRow = row-1
            }
            let indexpath: NSIndexPath = NSIndexPath(forRow: row, inSection: 0)
            indexpathsInserted.append(indexpath)
        }
        if expansion == .expand {
            // Insert rows
            tableView.insertRowsAtIndexPaths(indexpathsInserted, withRowAnimation: .Fade)
        }else{
            // remove rows
            tableView.deleteRowsAtIndexPaths(indexpathsInserted, withRowAnimation: .Fade)
        }
        // indicates there is some expansion or shrinking by updating previous cell with plus, minus or none.
        if updateStateOfRow != -1 {
            let indexpath: NSIndexPath = NSIndexPath(forRow: updateStateOfRow, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexpath], withRowAnimation: .None)
        }
        
        
        return node
    }
    func visibleChilds(childs: [Child], inout indices: [String], index: NSInteger, inout cellsUpdatedHolder  cellsToBeUpdated: [NSInteger], inout expansionOption  expansion:  ExpansionOption) -> NSInteger {
        
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
    func closeAllVisibleCells(childs: [Child]) {
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


public class Node {
    
    // MARK: Cle - Customized
    // changed to public private(set) from private - so that user can read arrayChilds
    public private(set) var arrayChilds: [Child] = []
    // Cle -
    public var name: String = ""
    
    // identity key
    public var keyIdentity: String = ""
    
    // Private instances
    private var isVisibility = false    // This will visible or invisible no of rows based on selection.
    private var expandedRows = 0        // This will hold a total of visible rows under it.
    
    // Indecies helper property
    public var index = "-1"
    
    // public instances
    public var state: State = .none
    public var id: String = ""
    public var givenIndex: String = ""
    
    public init() {
        
    }
    public init(indexParam: String, idParam: String, givenIndexParam: String) {
        index = indexParam
        id = idParam
        keyIdentity = idParam
        givenIndex = givenIndexParam
    }
}

public class Parent: Node{
    
    public override init() {
        super.init()
    }
    public init(childs: () -> [Child]) {
        super.init()
        arrayChilds = childs()
        // print(arrayChilds)
    }
    public init(key: String){
        super.init()
        keyIdentity = key
    }
    public init(key: String ,childs: () -> [Child]) {
        super.init()
        keyIdentity = key
        arrayChilds = childs()
        // print(arrayChilds)
    }
}
public class Child: Node{
    
    public override init() {
        super.init()
    }
    public init(subChilds: () -> [Child]) {
        super.init()
        arrayChilds = subChilds()
        // print(arrayChilds)
    }
    public init(key: String){
        super.init()
        keyIdentity = key
    }
    public init(key: String, subChilds: () -> [Child]) {
        super.init()
        keyIdentity = key
        arrayChilds = subChilds()
        // print(arrayChilds)
    }
}










