////
////  CustomSegmentedControl.swift
////  FleetManagement
////
////  Created by user@89 on 22/04/25.
////
//
//import SwiftUI
//
//struct CustomSegmentedControl: View {
//    @Binding var selectedSegment: String
//    let segments: [String]
//
//    var body: some View {
//        HStack(spacing: 0) {
//            ForEach(segments, id: \.self) { segment in
//                Button(action: {
//                    selectedSegment = segment
//                }) {
//                    Text(segment)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 10)
//                        .background(selectedSegment == segment ? Color(hex: "#396BAF") : Color.clear)
//                        .foregroundColor(selectedSegment == segment ? .white : Color(hex: "#396BAF"))
//                        .cornerRadius(8)
//                }
//            }
//        }
//        .background(Color(hex: "#396BAF").opacity(0.1))
//        .cornerRadius(10)
//        .padding(.horizontal)
//    }
//}
//
//struct CustomSegmentedControl_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomSegmentedControl(selectedSegment: .constant("HMV"), segments: ["HMV", "LMV"])
//            .previewLayout(.sizeThatFits)
//    }
//}
