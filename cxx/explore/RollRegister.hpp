/* 
 * File:   RollRegister.hpp
 * Author: sthysel
 *
 * Created on October 29, 2011, 5:37 PM
 */

#ifndef ROLLREGISTER_HPP
#define	ROLLREGISTER_HPP

#include <map>
#include <list>
#include <string>

using namespace std;

class RollRegister {
public:

    RollRegister();
    RollRegister(const RollRegister& orig);
    virtual ~RollRegister();

    /**
     * Record a rolled value
     * @param name
     * @param rollValue
     */
    void record(std::string name, int rollValue);

private:
    typedef list<int> RollValues;
    typedef map<std::string, RollValues> RollMap;
    
    RollMap rollMap_;
};

#endif	/* ROLLREGISTER_HPP */

