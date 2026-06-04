#ifndef IO_GENERATOR_OUTER_H
#define IO_GENERATOR_OUTER_H
extern const int PI_WIDTH = 12;
extern const int PO_WIDTH = 9;
void io_generator_outer(bool* pi, bool* po) {
    bool n0 = false;
    bool n1 = pi[0];
    bool n2 = pi[1];
    bool n3 = pi[2];
    bool n4 = pi[3];
    bool n5 = pi[4];
    bool n6 = pi[5];
    bool n7 = pi[6];
    bool n8 = pi[7];
    bool n9 = pi[8];
    bool n10 = pi[9];
    bool n11 = pi[10];
    bool n12 = pi[11];
    bool n13 = !n6 && n5;
    bool n14 = n6 && n5;
    bool n15 = n7 && n5;
    bool n16 = n15 && !n14;
    bool n17 = !n15 && n14;
    bool n18 = !n17 && !n16;
    bool n19 = !n18 && n5;
    bool n20 = n15 && n14;
    bool n21 = n20 && n5;
    bool n22 = n20 && n1;
    bool n23 = n22 && n5;
    bool n24 = n20 && n2;
    bool n25 = n9 && n5;
    bool n26 = n25 && !n20;
    bool n27 = !n26 && !n24;
    bool n28 = !n27 && n5;
    bool n29 = n20 && n3;
    bool n30 = n10 && n5;
    bool n31 = n30 && !n20;
    bool n32 = !n31 && !n29;
    bool n33 = !n32 && n5;
    bool n34 = n20 && n4;
    bool n35 = n11 && n5;
    bool n36 = n35 && !n20;
    bool n37 = !n36 && !n34;
    bool n38 = !n37 && n5;
    bool n39 = n8 && n5;
    bool n40 = n12 && n5;
    po[2] = n13;
    po[3] = n19;
    po[4] = n21;
    po[5] = n23;
    po[6] = n28;
    po[7] = n33;
    po[8] = n38;
    po[0] = n39;
    po[1] = n40;
}
#endif