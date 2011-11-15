/* 
 * File:   main.cpp
 * Author: sthysel
 *
 * Created on October 28, 2011, 9:23 PM
 */

#include <iostream>

#include "Dice.hpp"
#include "RollRegister.hpp"

using namespace std;

int main(int argc, char** argv) {
    Dice dice1("Red");
    Dice dice2("Black");
    RollRegister reg;

    for (int i = 0; i < 100; i++) {
        dice1.roll();
        reg.record(dice1.getName(), dice1.getValue());
        dice2.roll();
        reg.record(dice2.getName(), dice2.getValue());
        cout << dice1.getName() << ":" << dice1.getValue() << ", " << dice2.getName() << ":" << dice2.getValue() << endl;
    }
    return 0;
}

