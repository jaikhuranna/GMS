//
//  BookingService.swift
//  fleetManagementSystem
//
//  Created by user@61 on 30/04/25.
//


import Combine
import FirebaseFirestore

class BookingService: ObservableObject {
  @Published var booking: BookingRequest?

  private var listener: ListenerRegistration?
  private let db = Firestore.firestore()

    init(driverId: String) {
        // Listen for exactly one “pending” booking assigned to this driver
        listener = db.collection("bookingRequests")
            .whereField("driverId", isEqualTo: driverId)
            .whereField("status", isEqualTo: "pending")
            .limit(to: 1)
            .addSnapshotListener { [weak self] snap, err in
                guard
                    let doc = snap?.documents.first,
                    let br  = BookingRequest(doc)
                else { return }
                DispatchQueue.main.async {
                    self?.booking = br
                }
            }
    }
  deinit {
    listener?.remove()
  }
}
