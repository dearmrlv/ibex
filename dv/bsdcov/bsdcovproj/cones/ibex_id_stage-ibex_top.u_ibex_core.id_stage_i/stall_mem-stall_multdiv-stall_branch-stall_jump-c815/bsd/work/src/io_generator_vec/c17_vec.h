void io_generator_outer_vec(uint32_t* pi, uint32_t* po) {
    uint32_t n0 = 0;
    uint32_t n1 = pi[0];
    uint32_t n2 = pi[1];
    uint32_t n3 = pi[2];
    uint32_t n4 = pi[3];
    uint32_t n5 = pi[4];
    uint32_t n6 = n4 & n3;
    uint32_t n7 = ~n6 & n2;
    uint32_t n8 = n3 & n1;
    uint32_t n9 = ~n8 & ~n7;
    uint32_t n10 = ~n6 & n5;
    uint32_t n11 = ~n10 & ~n7;
    po[0] = ~n9;
    po[1] = ~n11;
}
