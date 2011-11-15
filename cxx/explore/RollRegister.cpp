/* 
 * File:   RollRegister.cpp
 * Author: sthysel
 * 
 * Created on October 29, 2011, 5:37 PM
 */

#include "RollRegister.hpp"

RollRegister::RollRegister() {
}

RollRegister::RollRegister(const RollRegister& orig) {
}

RollRegister::~RollRegister() {
}

void
RollRegister::record(string name, int rollValue) {
    rollMap_[name].push_back(rollValue);
}