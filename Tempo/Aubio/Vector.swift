//
//  Vector.swift
//  Tempo
//
//  Created by mxa on 27.09.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import aubio
import Foundation

extension Aubio {
    class Vector {
        internal let _vector: UnsafeMutablePointer<fvec_t>!
        
        init(length: UInt32) {
            self._vector = new_fvec(length)
        }
        
//        func fill(from bufferPointer: UnsafeMutableBufferPointer<Float>) {
//            self.fill(from: bufferPointer.baseAddress!, length: bufferPointer.count)
//        }

        func fill(from pointer: UnsafeMutablePointer<Float>, length: Int) {
            let bytesToCopy = min(length, self.length)
            let bytesToZero = self.length - bytesToCopy
            memcpy(self._vector.pointee.data, pointer, bytesToCopy)
            memset(self._vector.pointee.data + bytesToCopy, 0, bytesToZero)
        }

        deinit {
            del_fvec(self._vector)
        }
        
        var length: Int {
            return Int(self._vector.pointee.length)
        }
        
        func getSample(position: UInt32) -> Float {
            return fvec_get_sample(self._vector, position)
        }
        
        subscript(index: Int) -> Float {
            return self._vector.pointee.data[index]
        }
    }
}
