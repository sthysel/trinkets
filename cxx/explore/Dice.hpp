/* 
 * File:   Dice.hpp
 * Author: sthysel
 *
 * Created on October 28, 2011, 9:44 PM
 */

#ifndef DICE_HPP
#define	DICE_HPP

#include <string>

class Dice {
public:
    Dice(std::string name);
    Dice(const Dice& orig);
    virtual ~Dice();
    
    /**
     * Roll the dice
     */
    void roll();
    
    /**
     * Get the current dice value
     * @return value
     */
    int getValue();
    
    /**
     * Name of the dice
     * @return 
     */
    std::string getName();
    
private:
    std::string name_;
    int value_;
    
};

#endif	/* DICE_HPP */

