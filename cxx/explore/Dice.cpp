/* 
 * File:   Dice.cpp
 * Author: sthysel
 * 
 * Created on October 28, 2011, 9:44 PM
 */

#include <stdlib.h>
#include <ctime>
#include <string>
#include "Dice.hpp"

Dice::Dice(std::string name) {
    srand(time(0));
    name_ = name;
}

Dice::Dice(const Dice& orig) {
}

Dice::~Dice() {
}

void Dice::roll() {
    value_ = random() % 6 + 1;
}

int Dice::getValue() {
    return value_; 
}

std::string Dice::getName() {
    return name_;
}