library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.common.all;

entity decode is
    port (
        inst_in     : in std_logic_vector(xlen_c - 1 downto 0);
        rs1_out     : out std_logic_vector(raw_c - 1 downto 0);
        rs2_out     : out std_logic_vector(raw_c - 1 downto 0);
        rd_out      : out std_logic_vector(raw_c - 1 downto 0);
        aluctrl_out : out std_logic_vector(aluctrlw_c - 1 downto 0);
        imm_out     : out std_logic_vector(xlen_c - 1 downto 0);
        en_imm_out  : out std_logic; --- Use immediate instead of rs2 for ALU
        pc2rs1_out  : out std_logic;
    );
end entity decode;

-------------------------------------------------------------------------------

architecture rtl of decode is
    --- Bit position constants
    constant rs1_msb : integer := 19;
    constant rs1_lsb : integer := 15;
    constant rs2_msb : integer := 24;
    constant rs2_lsb : integer := 20;
    constant rd_msb : integer := 11;
    constant rd_lsb : integer := 7;
    constant imm_sign : integer := 31;
    constant funct3_msb : integer := 14;
    constant funct3_lsb : integer := 12;
    constant funct7_msb : integer := 31;
    constant funct7_lsb : integer := 25;
    constant opcode_msb : integer := 6;
    constant opcode_lsb : integer := 2;

    alias opcode_a : std_logic_vector(4 downto 0) is inst_in(opcode_msb downto opcode_lsb);
    alias rs1_a : std_logic_vector(4 downto 0) is inst_in(rs1_msb downto rs1_lsb);
    alias rs2_a : std_logic_vector(4 downto 0) is inst_in(rs2_msb downto rs2_lsb);
    alias rd_a : std_logic_vector(4 downto 0) is inst_in(rd_msb downto rd_lsb);
    alias funct3_a : std_logic_vector(4 downto 0) is inst_in(funct3_msb downto funct3_lsb);
    alias sign_a : std_logic is inst_in(imm_sign);
    alias shtype_a : std_logic is inst_in(30);

    --- Instruction format types
    type instr_format is (r_type, i_type, s_type, u_type, b_type, j_type);
    signal opcode : opcode_t;
    signal itype : instr_format;

    function b_immediate(inst : std_logic_vector(xlen_c - 1 downto 0)) return std_logic_vector is
        variable imm : std_logic_vector(xlen_c - 1 downto 0);
    begin
        imm(31 downto 12) <= (others => inst(imm_sign));
        imm(11) <= inst(7);
        imm(10 downto 5) <= inst(30 downto 25);
        imm(4 downto 1) <= inst(11 downto 8);
        imm(0) <= '0';
        return imm;
    end function b_immediate;

    function i_immediate(inst : std_logic_vector(xlen_c - 1 downto 0)) return std_logic_vector is
        variable imm : std_logic_vector(xlen_c - 1 downto 0);
    begin
        imm(31 downto 11) <= (others => inst(imm_sign));
        imm(10 downto 5) <= inst(30 downto 25);
        imm(4 downto 1) <= inst(24 downto 21);
        imm(0) <= inst(20);
        return imm;
    end function i_immediate;

    function u_immediate(inst : std_logic_vector(xlen_c - 1 downto 0)) return std_logic_vector is
        variable imm : std_logic_vector(xlen_c - 1 downto 0);
    begin
        imm(31) <= inst(imm_sign);
        imm(30 downto 12) <= inst(30 downto 12);
        imm(11 downto 0) <= (others => '0');
        return imm;
    end function i_immediate;
begin

    opcode <= opcode_t'val(to_integer(unsigned(inst_in(opcode_msb downto opcode_lsb))));

    build_imm : process (itype)
    begin
        case itype is
            when i_type =>

            when s_type =>
                imm_out(31 downto 11) <= (others => sign_a);
                imm_out(10 downto 5) <= inst_in(30 downto 25);
                imm_out(4 downto 1) <= inst_in(11 downto 8);
                imm_out(0) <= inst_in(7);

            when u_type =>

            when j_type =>
                imm_out(31 downto 20) <= (others => sign_a);
                imm_out(19 downto 12) <= inst_in(19 downto 12);
                imm_out(11) <= inst_in(20);
                imm_out(10 downto 5) <= inst_in(30 downto 25);
                imm_out(4 downto 1) <= inst_in(24 downto 21);
                imm_out(0) <= '0';

            when others =>
                imm_out <= (others => '0');

        end case;
    end process build_imm;

    do_op : process (sensitivity_list)
        type op_imm_t is (addi, slli, slti, sltiu, xori, srli, ori, andi);
    begin
        rs1_out <= rs1_a;
        rs2_out <= rs2_a;
        rd_out <= rd_a;
        aluctrl_out <= aluop2slv(alu_add);
        imm_out <= (others => '0');
        en_imm_out <= '0';
        pc2rs1_out <= '0';

        case opcode is
            when op_imm =>
                imm_out <= i_immediate(inst_in);
                en_imm_out <= '1';

                case op_imm_t'val(to_integer(unsigned(funct3_a))) is
                    when addi =>
                        aluctrl_out <= aluop2slv(alu_add);

                    when slti =>
                        aluctrl_out <= aluop2slv(alu_lt);
                    when sltiu =>
                        aluctrl_out <= aluop2slv(alu_ltu);

                    when andi =>
                        aluctrl_out <= aluop2slv(alu_and);
                    when ori =>
                        aluctrl_out <= aluop2slv(alu_or);
                    when xori =>
                        aluctrl_out <= aluop2slv(alu_xor);

                    when slli =>
                        aluctrl_out <= aluop2slv(alu_sll);
                    when srli =>
                        if shtype_a = '1' then
                            aluctrl_out <= aluop2slv(alu_srl);
                        else
                            aluctrl_out <= aluop2slv(alu_sra);
                            imm_out(10) <= '0';
                        end if;
                    when others => aluctrl_out <= aluop2slv(alu_add);
                end case;

            when lui =>
                imm_out <= u_immediate(inst_in);
                en_imm_out <= '1';
                aluctrl_out <= aluop2slv(alu_add);
                rs1_out <= (others => '0');

            when auipc =>
                imm_out <= u_immediate(inst_in);
                en_imm_out <= '1';
                aluctrl_out <= aluop2slv(alu_add);
                pc2rs1_out <= '1';
            when others =>
        end case;
    end process do_op;
end architecture rtl;
