import Foundation

final class CallStation {
    var usersArray: Array<User> = []
    var callsArray: Array<Call> = []
}

extension CallStation: Station {
    func users() -> [User] {
        if usersArray.isEmpty {
            return []
        }
        return Array(usersArray)
    }
    
    func add(user: User) {
        if !usersArray.contains(user) {
            usersArray.append(user)
        }
    }
    
    func remove(user: User) {
        if let index = usersArray.firstIndex(of: user) {
            usersArray.remove(at: index)
            
            for i in callsArray.indices {
                if (callsArray[i].incomingUser == user || callsArray[i].outgoingUser == user) && (callsArray[i].status == .talk || callsArray[i].status == .calling) {
                    callsArray[i].status = .ended(reason: CallEndReason.error)
                }
            }
            
        }
    }
    
    func execute(action: CallAction) -> CallID? {
        
        switch action {
        case .start(let user1, let user2):
            if !usersArray.contains(user1) && !usersArray.contains(user2) { return nil }
            print("\(user1) calls to \(user2)")
            
            let callID = UUID()
            var status: CallStatus = usersArray.contains(user2) ? .calling : .ended(reason: CallEndReason.error)
            for i in callsArray.indices {
                if (callsArray[i].incomingUser == user2 || callsArray[i].outgoingUser == user2) && callsArray[i].status == .talk {
                    status = .ended(reason: CallEndReason.userBusy)
                }
            }
            
            let newCall = Call(id: callID, incomingUser: user1, outgoingUser: user2, status: status)
            callsArray.append(newCall)
            return newCall.id
            
        case .answer(let user2):
            if usersArray.contains(user2){
                for i in callsArray.indices {
                    if callsArray[i].outgoingUser == user2 && callsArray[i].status == .calling {
                        callsArray[i].status = .talk
                        return callsArray[i].id
                    }
                }
            }
            return nil
            
        case .end(let user):
            for i in callsArray.indices {
                if callsArray[i].incomingUser == user && callsArray[i].status == .talk {
                    callsArray[i].status = .ended(reason: CallEndReason.end)
                    return callsArray[i].id
                }
                if callsArray[i].outgoingUser == user && callsArray[i].status == .talk {
                    callsArray[i].status = .ended(reason: CallEndReason.end)
                    return callsArray[i].id
                }
                if callsArray[i].outgoingUser == user && callsArray[i].status == .calling {
                    callsArray[i].status = .ended(reason: CallEndReason.cancel)
                    return callsArray[i].id
                }
            }
            return nil
        }
    }
    
    func calls() -> [Call] {
        if callsArray.isEmpty {
            return []
        }
        return Array(callsArray)
    }
    
    func calls(user: User) -> [Call] {
        var userArrayCalls: [Call] = []
        for item in callsArray {
            if item.outgoingUser == user || item.incomingUser == user {
                userArrayCalls.append(item)
            }
        }
        return userArrayCalls
    }
    
    func call(id: CallID) -> Call? {
        for item in callsArray {
            if item.id == id {
                return item
            }
        }
        return nil
    }
    
    func currentCall(user: User) -> Call? {
        for currentUser in callsArray where (currentUser.incomingUser == user && (currentUser.status == .calling || currentUser.status == .talk)) {
            return currentUser
        }
        
        for currentUser in callsArray where (currentUser.outgoingUser == user && (currentUser.status == .calling || currentUser.status == .talk)) {
            return currentUser
        }
        
        return nil
    }
}
