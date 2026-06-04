#ifndef IO_GENERATOR_OUTER_H
#define IO_GENERATOR_OUTER_H
extern const int PI_WIDTH = 5;
extern const int PO_WIDTH = 2;
void io_generator_outer(bool* pi, bool* po) {
    bool n0 = false;
    bool n1 = pi[0];
    bool n2 = pi[1];
    bool n3 = pi[2];
    bool n4 = pi[3];
    bool n5 = pi[4];
    bool n6 = n4 && n3;
    bool n7 = !n6 && n2;
    bool n8 = n3 && n1;
    bool n9 = !n8 && !n7;
    bool n10 = !n6 && n5;
    bool n11 = !n10 && !n7;
    po[0] = !n9;
    po[1] = !n11;
}
#endif