`timescale 1ns/10ps
module codenum(clk,rst_n,en_1,en_2,data_in,id0_r,id1_r,code_0,code_1,code_2,code_3,code_4,code_5,code_6,code_7,code_8,code_9);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
  input clk;
  input rst_n;
  input [3:0]data_in;
  input en_1;//ʹ�ܶ�1������Чʱcodenumģ��ִ�м�������
  input en_2;//ʹ�ܶ�2������Чʱcodenumģ��ִ��Ƶ�ʸ��¹���
  input [3:0]id0_r;//����Ƶ����С�ַ�������Ƶ��
  input [3:0]id1_r;//����Ƶ������ַ�������Ƶ��
  
  output [7:0]code_0;
  output [7:0]code_1;
  output [7:0]code_2;
  output [7:0]code_3;
  output [7:0]code_4;
  output [7:0]code_5;
  output [7:0]code_6;
  output [7:0]code_7;
  output [7:0]code_8;
  output [7:0]code_9;//���0-9�ַ���Ƶ��
/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/  
  reg [7:0]code_num[9:0];//��¼0-9�ַ���Ƶ�ʣ�λ��Ϊ8;code_numΪ10��8λ�洢��
						//��Ϊ����Ϊ256�����У������������Ϊ8λ
  parameter times_max=8'b1111_1111;//����Ƶ��ֵ              
  integer i;
  
  always@(posedge clk)
    begin
      if(!rst_n)
        for(i=0;i<10;i=i+1)
          code_num[i]<=0;
      else if(en_1)//en_1��Ч�����м���
    case(data_in)
		4'b0000: code_num[0]<=code_num[0]+1;
		4'b0001: code_num[1]<=code_num[1]+1;
		4'b0010: code_num[2]<=code_num[2]+1;
		4'b0011: code_num[3]<=code_num[3]+1;
		4'b0100: code_num[4]<=code_num[4]+1;
		4'b0101: code_num[5]<=code_num[5]+1;
		4'b0110: code_num[6]<=code_num[6]+1;
		4'b0111: code_num[7]<=code_num[7]+1; 
		4'b1000: code_num[8]<=code_num[8]+1;
		4'b1001: code_num[9]<=code_num[9]+1;  
    endcase
      else if(en_2)//en_2��Ч������Ƶ��
       begin
		code_num[id1_r]<=code_num[id1_r]+code_num[id0_r];//��Ƶ�ʴ����Сֵ
		code_num[id0_r]<=times_max;//���Ƶ�ʸ�ֵ����Сֵ
      end
   end				   

  assign code_0=code_num[0];
  assign code_1=code_num[1];
  assign code_2=code_num[2];
  assign code_3=code_num[3];
  assign code_4=code_num[4];
  assign code_5=code_num[5];
  assign code_6=code_num[6];
  assign code_7=code_num[7];
  assign code_8=code_num[8];
  assign code_9=code_num[9];//���洢��Ƶ���������
  
endmodule
/*-----------------------------------------------------------------------
		end of model codenum
------------------------------------------------------------------------*/

module codetree(clk,rst_n,en,vic0,vic1,tree0_tmp,tree1_tmp);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
  input clk;
  input rst_n;
  input en;//����������Ч������controlģ���coding_sign�˿�
  input [3:0]vic0;
  input [3:0]vic1;//��������selectorģ���Ƶ����С����С�ַ����
  
  output [9:0]tree0_tmp;
  output [9:0]tree1_tmp;//���Ƶ����С����С�ַ�����

/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/
  reg [9:0]code_tree[9:0];//��¼0-9�ַ���������,10��10λ��code_tree
  
  always@(posedge clk)
    begin
     if(!rst_n) 
        begin
           code_tree[0]<=10'b0000000001;
           code_tree[1]<=10'b0000000010;
           code_tree[2]<=10'b0000000100;
           code_tree[3]<=10'b0000001000;
           code_tree[4]<=10'b0000010000;
           code_tree[5]<=10'b0000100000;
           code_tree[6]<=10'b0001000000;
           code_tree[7]<=10'b0010000000;
           code_tree[8]<=10'b0100000000;
           code_tree[9]<=10'b1000000000;//����ʼ��Ϊ��������ʽ
        end
     else if(en)//����������Ч,�����º��������"��Сֵ"����Ƶ�ʸ���һ��
        code_tree[vic1]<=code_tree[vic0]+code_tree[vic1];
  end
  
  assign tree0_tmp=code_tree[vic0];
  assign tree1_tmp=code_tree[vic1];//���Ƶ����С����С�ַ�����
  
endmodule
module control(clk,rst_n,start,start_keep,coding_sign,
               pipe1,pipe2,pipe3,pipe4,pipe5,pipe6,pipe7,pipe8,
               refresh,coding_encoder,fsm_start);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/ 
  input clk;
  input rst_n;
  input start;
  
  output start_keep;//����ʹ���ź�
  output coding_sign;//����ʹ���ź�
  
  output reg pipe1;
  output reg pipe2;
  output reg pipe3;
  output reg pipe4;
  output reg pipe5;
  output reg pipe6;
  output reg pipe7;
  output reg pipe8;//�˼���ˮ�ߵ�ʹ���ź�
  
  output reg refresh;//����Ƶ�ʣ�������ʹ���ź�
  output reg coding_encoder;//������ˮ�ߺ�encoderģ��ı���ʹ���ź�
  output  fsm_start;//outputģ��FSM��ʼ�ź�
     
  parameter times=256;//256��������������
  parameter times_code=9;//9�α���
/*------------------------------------------------------------------------
        start_keep
------------------------------------------------------------------------*/    
  reg start_reg;
  reg fsm_start_reg;
  reg [7:0]counter; 

  always@(posedge clk)
    begin
      if(!rst_n)
        start_reg<=0;
      else if(counter==times-1)
        start_reg<=0;
      else if(start)
        start_reg<=1;       
    end

  always@(posedge clk)
    begin
      if(!rst_n)
        counter<=0;
      else if(counter==times-1)
        counter<=0;
      else if(start_reg)
        counter<=counter+1;      
    end  
  
  assign start_keep=start_reg;
/*------------------------------------------------------------------------
        coding_sign
------------------------------------------------------------------------*/   
  reg [3:0]curr_st;
  reg [3:0]next_st;
  reg [7:0]counter_code;
  parameter S0=0;
  parameter S1=1;
  parameter S2=2;
  parameter S3=3;
  parameter S4=4;
  parameter S5=5;
  parameter S6=6;
  parameter S7=7;
  parameter S8=8;
  parameter S9=9;
  parameter S10=10;

  
  always@(posedge clk)
    begin
    if(!rst_n)
	curr_st<=S0;
    else
	curr_st<=next_st;
	end

  always@(posedge clk)
    begin
     if(next_st==S0)
      counter_code<=0;
     else if(next_st==S1)
      counter_code<=counter_code+1;
    end
	
  always@(*)
    case(curr_st)
     S0:
      if(counter==times-1)
        next_st=S1;
      else
        next_st=S0;	 
     S1:next_st=S2; 
     S2:next_st=S3;
     S3:next_st=S4;
     S4:next_st=S5;
     S5:next_st=S6;
     S6:next_st=S7;
     S7:next_st=S8;
     S8:next_st=S9;
     S9:next_st=S10;
     S10:
      if(counter_code==times_code)
        next_st=S0;
      else
        next_st=S1; 
     default:next_st=S0;
    endcase
  
 assign coding_sign=(curr_st==S1);  
    

/*------------------------------------------------------------------------
        fsm_start
------------------------------------------------------------------------*/  
  always@(posedge clk)
    begin
	  if(!rst_n)
        fsm_start_reg<=0;
      else if((curr_st==S10)&&(next_st==S0))
        fsm_start_reg<=1;
	  else
	    fsm_start_reg<=0;
    end	
	
assign fsm_start=fsm_start_reg; 
/*------------------------------------------------------------------------
       pipelineʹ���ź�
------------------------------------------------------------------------*/  
  
   always@(posedge clk)
    begin
        pipe1<=coding_sign;
    end	

   always@(posedge clk)
    begin
        pipe2<=pipe1;
    end	
	
   always@(posedge clk)
    begin
        pipe3<=pipe2;
    end	
	
   always@(posedge clk)
    begin
        pipe4<=pipe3;
    end

   always@(posedge clk)
    begin
        pipe5<=pipe4;
    end	
	
   always@(posedge clk)
    begin
        pipe6<=pipe5;
    end	
	
   always@(posedge clk)
    begin
        pipe7<=pipe6;
    end	
   
   always@(posedge clk)
    begin
        pipe8<=pipe7;
    end		
		
   always@(posedge clk)
    begin
       refresh<=pipe8;
    end		
		
   always@(posedge clk)
    begin
       coding_encoder<=refresh;
    end	
	
 endmodule 
 module data_fifo ( rst, clk, rd_en, wr_en, wr_data, rd_data);
 
 parameter DEPTH=256;//fifo���
 parameter WIDTH=4;    //fifo���
                                                 
 /*------------------------------------------------------------------------
         Ports
 ------------------------------------------------------------------------*/
 input                                    rst;
 input                                    clk;
 input                                    rd_en;                //fifo��ʹ�� 
 input                                    wr_en;                //fifoдʹ��
 input    [WIDTH-1:0]            wr_data;            //fifo������
 output[WIDTH-1:0]            rd_data;            //fifoд����
 
 /*------------------------------------------------------------------------
         Internal Signal Declarations
 ------------------------------------------------------------------------*/
 reg [7:0]                      rd_ptr;              //fifo��ָ��
 reg [7:0]                      wr_ptr;              //fifoдָ��
 reg                            rd_turn;            //fifo��ָ�뷭ת
 reg                            wr_turn;            //fifoдָ�뷭ת
 reg [WIDTH-1:0]                rd_data_reg;    //
 reg [WIDTH-1:0]                fifo_mem [DEPTH-1:0];    //fifo�洢
 integer i;
 
 
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
                 rd_ptr <= 0;
                 rd_turn <= 0;
       end
     else if (rd_en)
       begin
                 if (rd_ptr==DEPTH-1)
                     begin
                         rd_ptr <= 0;
                         rd_turn <= ~rd_turn;
                     end
                 else
                     begin
                         rd_ptr <= rd_ptr + 1;
                     end
       end
   end
 
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
                 wr_ptr <= 0;
                 wr_turn <= 0;
       end
     else if (wr_en)
       begin
                 if (wr_ptr==DEPTH-1)
                     begin
                         wr_ptr <= 0;
                         wr_turn <= ~wr_turn;
                     end
                 else
                     begin
                         wr_ptr <= wr_ptr + 1;
                     end
       end
   end  
   
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
           for(i=0;i<DEPTH;i=i+1)
                     begin
                         fifo_mem[i] <= 0; 
                     end
       end
     else if (wr_en)
       begin
           fifo_mem[wr_ptr] <= wr_data;
       end
   end
   
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
           rd_data_reg <= 0;
       end
     else if (rd_en)
       begin
           rd_data_reg <= fifo_mem[rd_ptr];
       end
   end
 
 assign rd_data = rd_data_reg;  
 
 endmodule
module encoder(clk,rst_n,en,r_tree,
 tree_r0,tree_r1,codehf_0,codehf_1,codehf_2,codehf_3,codehf_4,codehf_5,codehf_6,codehf_7,codehf_8,codehf_9,
 code_length_0,code_length_1,code_length_2,code_length_3,code_length_4,code_length_5,code_length_6,code_length_7,code_length_8,code_length_9);
 /*------------------------------------------------------------------------
         Ports
 ------------------------------------------------------------------------*/
   input clk;
   input rst_n;
   input en;//����������Ч��ģ����б��룬��������controlģ���coding_sign_tree�˿�
   input r_tree;//ʹ�ܶˣ�����Чʱ��������codetreeģ�������Ϣ���ӳ�һ�ģ������ӳ٣���������controlģ���coding_sign_delay9�˿�
   input [9:0]tree_r0;//��������codetreeģ�����С��
   input [9:0]tree_r1;//��������codetreeģ��Ĵ�С��
   
   output [6:0]codehf_0;
   output [6:0]codehf_1;
   output [6:0]codehf_2;
   output [6:0]codehf_3;
   output [6:0]codehf_4;
   output [6:0]codehf_5;
   output [6:0]codehf_6;
   output [6:0]codehf_7;
   output [6:0]codehf_8;
   output [6:0]codehf_9;//���0-9�ַ��Ĺ���������
    
   output [2:0]code_length_0;
   output [2:0]code_length_1;
   output [2:0]code_length_2;
   output [2:0]code_length_3;
   output [2:0]code_length_4;
   output [2:0]code_length_5;
   output [2:0]code_length_6;
   output [2:0]code_length_7;
   output [2:0]code_length_8;
   output [2:0]code_length_9; //���0-9�ַ��Ĺ��������볤�ȣ���outputģ���Ա��ڲ��������
   
 /*------------------------------------------------------------------------
         Internal Signal Declarations
 ------------------------------------------------------------------------*/  
   reg [6:0]code_hoff[9:0]; //�洢���������룬λ��Ϊ7λ
   reg [6:0]code_sign[9:0]; //�洢code_sign����
   reg [2:0]code_length[9:0];//�洢���������볤��
   
   reg [9:0]tree_sum;//��С���ʹ�С���ĺ�
   reg [9:0]tree_1;//��С��
   integer i,j;
   
 always@(posedge clk)
   begin
   if (!rst_n)
     begin
     code_hoff[0]<=7'b000_0000;
     code_hoff[1]<=7'b000_0000;
     code_hoff[2]<=7'b000_0000;
     code_hoff[3]<=7'b000_0000;
     code_hoff[4]<=7'b000_0000;
     code_hoff[5]<=7'b000_0000;
     code_hoff[6]<=7'b000_0000;
     code_hoff[7]<=7'b000_0000;
     code_hoff[8]<=7'b000_0000;
     code_hoff[9]<=7'b000_0000;//���ĳ�ʼ��Ϊ0�����Ա������ֻ�ñ�"1"
     
     code_sign[0]<=7'b000_0001;
     code_sign[1]<=7'b000_0001;
     code_sign[2]<=7'b000_0001;
     code_sign[3]<=7'b000_0001;
     code_sign[4]<=7'b000_0001;
     code_sign[5]<=7'b000_0001;
     code_sign[6]<=7'b000_0001;
     code_sign[7]<=7'b000_0001;
     code_sign[8]<=7'b000_0001;
     code_sign[9]<=7'b000_0001;//code_sign�ĳ�ʼ��Ϊ1��ÿ�θ�������һλ
     
     code_length[0]<=0;
     code_length[1]<=0;
     code_length[2]<=0;
     code_length[3]<=0;
     code_length[4]<=0;
     code_length[5]<=0;
     code_length[6]<=0;
     code_length[7]<=0;
     code_length[8]<=0;
     code_length[9]<=0;
     end
   else if(en)//ģ����б���
    begin
     for(i=0;i<10;i=i+1)
     if(tree_1[i]==1)     
      code_hoff[i]<=code_hoff[i]|code_sign[i];    
      
     for(j=0;j<10;j=j+1)
      if(tree_sum[j]==1)
       begin     
        code_sign[j]<=code_sign[j]<<1;
        code_length[j]<=code_length[j]+1;
       end   
    end
 end
 
 always@(posedge clk)//��������Ϣ���������
    begin
     if(r_tree)
      begin
       tree_sum<=tree_r0+tree_r1;
       tree_1<=tree_r1;
      end
    end
 
 /*-----------------------------------------------------------------------------------------
                                     ���huffmann code
 ------------------------------------------------------------------------------------------*/
    assign codehf_0=code_hoff[0];
    assign codehf_1=code_hoff[1];
    assign codehf_2=code_hoff[2];
    assign codehf_3=code_hoff[3];
    assign codehf_4=code_hoff[4];
    assign codehf_5=code_hoff[5];
    assign codehf_6=code_hoff[6];
    assign codehf_7=code_hoff[7];
    assign codehf_8=code_hoff[8];
    assign codehf_9=code_hoff[9];
 
 /*-----------------------------------------------------------------------------------------
                                     ���huffmann length
 ------------------------------------------------------------------------------------------*/
    assign code_length_0=code_length[0];
    assign code_length_1=code_length[1];
    assign code_length_2=code_length[2];
    assign code_length_3=code_length[3];
    assign code_length_4=code_length[4];
    assign code_length_5=code_length[5];
    assign code_length_6=code_length[6];
    assign code_length_7=code_length[7];
    assign code_length_8=code_length[8];
    assign code_length_9=code_length[9];
 
 endmodule
  module Output(clk,data_in,rst_n,fsm_start,
              codehf_r0,codehf_r1,codehf_r2,codehf_r3,codehf_r4,codehf_r5,codehf_r6,codehf_r7,codehf_r8,codehf_r9,
              length_r0,length_r1,length_r2,length_r3,length_r4,length_r5,length_r6,length_r7,length_r8,length_r9,
              output_data,output_start,output_done,fifo_rd);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input clk;
input [3:0]data_in;
input rst_n;

input [6:0]codehf_r0;
input [6:0]codehf_r1;
input [6:0]codehf_r2;
input [6:0]codehf_r3;
input [6:0]codehf_r4;
input [6:0]codehf_r5;
input [6:0]codehf_r6;
input [6:0]codehf_r7;
input [6:0]codehf_r8;
input [6:0]codehf_r9;//��������encoderģ��Ĺ���������


input [2:0]length_r0;
input [2:0]length_r1;
input [2:0]length_r2;
input [2:0]length_r3;
input [2:0]length_r4;
input [2:0]length_r5;
input [2:0]length_r6;
input [2:0]length_r7;
input [2:0]length_r8;
input [2:0]length_r9;//��������encoderģ��Ĺ��������볤��

input fsm_start;//outputģ��״̬����ʼ��־������controlģ�飬�ڱ�����������Ч

output reg output_data;//�������
output reg output_start;//�����ʼ��־
output reg output_done;//���������־

output fifo_rd;//��data_fifoģ��Ķ��ź�
/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/  

reg [6:0]hoff_reg; //�Ĵ����������
reg [6:0]hoff_reg_d; //�ӳٽ��յĹ���������
reg [2:0]length_reg; //�Ĵ���������볤��
reg [2:0]length_reg_d; //�ӳٽ��յĹ���������
reg  output_start_d;//�ӳ������ʼ��־
reg  output_done_d;//�ӳ����������־

reg [3:0]cnt_10; //��һ�����������
reg [3:0]cnt_output; //�������������
reg [3:0]cnt_output_d;//��������������ӳ�
reg [8:0]cnt_256;//�ڶ������������

parameter S0=3'b000;
parameter S1=3'b001;    
parameter S2=3'b010;
parameter S3=3'b011;
parameter S4=3'b100; //FSM��������
parameter L2=10;//��ʾ10���ַ�
parameter L4=256;//��ʾ256�������������г���


reg [2:0]curr_st;//FSM��ǰ״̬
reg [2:0]next_st;//FSM��һ����״̬

always@(posedge clk)//FSM����
  begin
   if(!rst_n)
     curr_st<=S0;
   else
     curr_st<=next_st;
  end

always@(*)//FSM��������
 begin
  case(curr_st)
    S0:
    begin
      if(fsm_start)//
        next_st=S1;
      else
        next_st=S0;
    end
    S1: next_st=S2;
    S2:
    begin
      if((cnt_output<length_reg-1)&&(cnt_10<=L2))
        next_st=S2;
      else if((cnt_output==length_reg-1)&&(cnt_10<L2))
        next_st=S1;
      else if((cnt_10==L2)&&(cnt_output==length_reg-1))
        next_st=S3;
      else
      next_st=S0;
    end
    S3: next_st=S4;
    S4:
    begin
      if((cnt_output<length_reg-1)&&(cnt_256<=L4))
        next_st=S4;
      else if((cnt_output==length_reg-1)&&(cnt_256<L4))
        next_st=S3;
      else if((cnt_256==L4)&&(cnt_output==length_reg-1))
        next_st=S0;
      else 
        next_st=S0;
    end
    default:next_st=S0;
   endcase
 end
/*------------------------------------------------------------------------
        ��һ�����������
------------------------------------------------------------------------*/ 
always@(posedge clk)
  begin
   if(!rst_n)
    cnt_10<=0;
   else if((cnt_10==L2)&&(cnt_output==length_reg-1))
    cnt_10<=0; 
   else if(next_st==S1)
    cnt_10<=cnt_10+1; 
  end
  
/*------------------------------------------------------------------------
        �������������
------------------------------------------------------------------------*/   
  
 always@(posedge clk)
  begin
   if(!rst_n)
    cnt_output<=0;
   else if(cnt_output==length_reg-1)
    cnt_output<=0; 
   else if((curr_st==S2)|((curr_st==S1)&(cnt_10!=1))|((curr_st==S4)|(curr_st==S3)))
    cnt_output<=cnt_output+1;
   end
  
 always@(posedge clk)
  begin
  cnt_output_d<=cnt_output;
  end
 /*------------------------------------------------------------------------
        �ڶ������������
------------------------------------------------------------------------*/   
  always@(posedge clk)
  begin
  if(!rst_n)
   cnt_256<=0;
  else if((cnt_256==L4)&&(cnt_output==length_reg-1))////???
   cnt_256<=0;
  else if(curr_st==S3)
   cnt_256<=cnt_256+1;  
  end
 /*------------------------------------------------------------------------
        ���չ���������
------------------------------------------------------------------------*/   
   always@(*)
   begin
    if(curr_st==S3|curr_st==S4)
      begin
       case(data_in)//����FIFO��������������
         4'b0000: hoff_reg_d=codehf_r0;
         4'b0001: hoff_reg_d=codehf_r1;
         4'b0010: hoff_reg_d=codehf_r2;
         4'b0011: hoff_reg_d=codehf_r3;
         4'b0100: hoff_reg_d=codehf_r4;
         4'b0101: hoff_reg_d=codehf_r5;
         4'b0110: hoff_reg_d=codehf_r6;
         4'b0111: hoff_reg_d=codehf_r7;
         4'b1000: hoff_reg_d=codehf_r8;
         4'b1001: hoff_reg_d=codehf_r9;
       default: hoff_reg_d=0;
       endcase
      end
   else if(curr_st==S1|curr_st==S2)
       begin
       case(cnt_10)//��������0-9�ַ������е�һ�������
         4'b0001: hoff_reg_d=codehf_r0;
         4'b0010: hoff_reg_d=codehf_r1;
         4'b0011: hoff_reg_d=codehf_r2;
         4'b0100: hoff_reg_d=codehf_r3;
         4'b0101: hoff_reg_d=codehf_r4;
         4'b0110: hoff_reg_d=codehf_r5;
         4'b0111: hoff_reg_d=codehf_r6;
         4'b1000: hoff_reg_d=codehf_r7;
         4'b1001: hoff_reg_d=codehf_r8;
         4'b1010: hoff_reg_d=codehf_r9;
       default: hoff_reg_d=0;
       endcase
      end  
   else
     hoff_reg_d=0;    
   end
   
  always@(posedge clk)
    begin
      hoff_reg<=hoff_reg_d;
    end
/*------------------------------------------------------------------------
        ���չ��������볤��
------------------------------------------------------------------------*/  
   always@(*)
   begin
    if(curr_st==S3|curr_st==S4)
      begin
       case(data_in)//����FIFO��������������
         4'b0000: length_reg_d=length_r0;
         4'b0001: length_reg_d=length_r1;
         4'b0010: length_reg_d=length_r2;
         4'b0011: length_reg_d=length_r3;
         4'b0100: length_reg_d=length_r4;
         4'b0101: length_reg_d=length_r5;
         4'b0110: length_reg_d=length_r6;
         4'b0111: length_reg_d=length_r7;
         4'b1000: length_reg_d=length_r8;
         4'b1001: length_reg_d=length_r9;
         default: length_reg_d=0;
       endcase
      end
   else if(curr_st==S1|curr_st==S2)
       begin
       case(cnt_10)//��������0-9�ַ������е�һ�������
         4'b0001: length_reg_d=length_r0;
         4'b0010: length_reg_d=length_r1;
         4'b0011: length_reg_d=length_r2;
         4'b0100: length_reg_d=length_r3;
         4'b0101: length_reg_d=length_r4;
         4'b0110: length_reg_d=length_r5;
         4'b0111: length_reg_d=length_r6;
         4'b1000: length_reg_d=length_r7;
         4'b1001: length_reg_d=length_r8;
         4'b1010: length_reg_d=length_r9;
         default: length_reg_d=0;
       endcase
      end  
   else
   length_reg_d=0;
   end   
   
  always@(posedge clk)
    begin
     length_reg<=length_reg_d;
    end
   
 /*------------------------------------------------------------------------
       �����ʼ��־��������־
------------------------------------------------------------------------*/   
   always@(posedge clk)
    begin
     if(!rst_n)
      output_start_d<=0;
     else if(next_st==S1&&curr_st==S0)
      output_start_d<=1;
     else 
      output_start_d<=0;   
    end
   
   always@(posedge clk)
      output_start<=output_start_d;
   
   always@(posedge clk)
     begin
      if(!rst_n)
       output_done_d<=0;
      else if(next_st==S0&&curr_st==S4)
       output_done_d<=1;
      else 
       output_done_d<=0;   
     end
   always@(posedge clk)
      output_done<=output_done_d;
 /*------------------------------------------------------------------------
       �������
------------------------------------------------------------------------*/     
   always@(*)
      begin
       case(length_reg-cnt_output_d-1)//
         4'b0000: output_data=hoff_reg[0];
         4'b0001: output_data=hoff_reg[1];
         4'b0010: output_data=hoff_reg[2];
         4'b0011: output_data=hoff_reg[3];
         4'b0100: output_data=hoff_reg[4];
         4'b0101: output_data=hoff_reg[5];
         4'b0110: output_data=hoff_reg[6];
         default: output_data=0;
       endcase
      end

assign fifo_rd=(next_st==S3);//�����FIFO�Ķ�ʹ���ź�

endmodule
module selector(clk,rst_n,coding_sign,pipe1,pipe2,pipe3,pipe4,pipe5,pipe6,pipe7,pipe8,code_r0,code_r1,code_r2,code_r3,code_r4,code_r5,code_r6,code_r7,code_r8,code_r9,id0,id1);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
  input clk;
  input rst_n;
  input coding_sign;//selectorģ���ʹ�ܶˣ��ڱ���������ִ��ѡ����
  input pipe1;
  input pipe2;
  input pipe3;
  input pipe4;
  input pipe5;
  input pipe6;
  input pipe7;
  input pipe8;//ʵ����ˮ�ߵĿ����źţ���controlģ���pipe1-pipe8�˿�
  
  input [7:0]code_r0;
  input [7:0]code_r1;
  input [7:0]code_r2;
  input [7:0]code_r3;
  input [7:0]code_r4;
  input [7:0]code_r5;
  input [7:0]code_r6;
  input [7:0]code_r7;
  input [7:0]code_r8;
  input [7:0]code_r9;//����0-9�ַ�Ƶ�ʶ˿ڣ���codenumģ���code_1-code_9�˿�
  
  output  [3:0]id0;
  output  [3:0]id1;//���Ƶ����С����С�ַ����
/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/ 
  reg [7:0]code_num_tmp[3:0];//�ȽϹ������õļĴ���
  reg [3:0]code_idx[5:0];//�ȽϹ������õļĴ���  
  reg [7:0]code_num_1[9:0]; //���Сֵ�洢Ƶ��
  
/*------------------------------------------------------------------------
        ����С����СƵ�ʣ��˲��������Ż��ǣ����ϲ��ĸ��ʷ���"��СƵ����"�����Ի�ý�С���뷽�
------------------------------------------------------------------------*/ 
 
  always@(posedge clk)
  begin
  
    if(coding_sign)//�����������Ч
	 begin
		code_num_tmp[0]<=(code_r0>=code_r1)?code_r1:code_r0;
		code_num_tmp[1]<=(code_r2>=code_r3)?code_r3:code_r2;
		code_num_tmp[2]<=(code_r4>=code_r5)?code_r5:code_r4;
		code_num_tmp[3]<=(code_r6>=code_r7)?code_r7:code_r6;
		code_idx[0]<=(code_r0>=code_r1)?1:0;
		code_idx[1]<=(code_r2>=code_r3)?3:2;
		code_idx[2]<=(code_r4>=code_r5)?5:4;
		code_idx[3]<=(code_r6>=code_r7)?7:6;
     end
  
    else if(pipe1)//��һ����ˮ
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_num_tmp[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_num_tmp[3]:code_num_tmp[2];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];
		code_idx[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_idx[3]:code_idx[2];  
     end
  
    else if(pipe2)//�ڶ�����ˮ
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];
		code_num_tmp[1]<=(code_r8>=code_r9)?code_r9:code_r8;//10�����Ƚ����һ�������Էŵ���ˮ�ߵĵڶ���
		code_idx[1]<=(code_r8>=code_r9)?9:8;//
     end
  
    else if(pipe3)//��������ˮ
		code_idx[4]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0]; 
 
    else if(pipe4)//���ļ���ˮ 
     begin  
		code_num_1[0]<=(id0==0)?8'b1111_1111:code_r0;  
		code_num_1[1]<=(id0==1)?8'b1111_1111:code_r1; 
		code_num_1[2]<=(id0==2)?8'b1111_1111:code_r2; 
		code_num_1[3]<=(id0==3)?8'b1111_1111:code_r3; 
		code_num_1[4]<=(id0==4)?8'b1111_1111:code_r4; 
		code_num_1[5]<=(id0==5)?8'b1111_1111:code_r5; 
		code_num_1[6]<=(id0==6)?8'b1111_1111:code_r6; 
		code_num_1[7]<=(id0==7)?8'b1111_1111:code_r7; 
		code_num_1[8]<=(id0==8)?8'b1111_1111:code_r8; 
		code_num_1[9]<=(id0==9)?8'b1111_1111:code_r9;//����Сֵ��ΪƵ�����ֵ���ٴ��ظ�����   
     end
  
    else if(pipe5)//���弶��ˮ���嵽�˼���ˮ���Сֵ������code_num_tmp��code_idx��Դ
	 begin
		code_num_tmp[0]<=(code_num_1[0]>=code_num_1[1])?code_num_1[1]:code_num_1[0];
		code_num_tmp[1]<=(code_num_1[2]>=code_num_1[3])?code_num_1[3]:code_num_1[2];
		code_num_tmp[2]<=(code_num_1[4]>=code_num_1[5])?code_num_1[5]:code_num_1[4];
		code_num_tmp[3]<=(code_num_1[6]>=code_num_1[7])?code_num_1[7]:code_num_1[6];

		code_idx[0]<=(code_num_1[0]>=code_num_1[1])?1:0;
		code_idx[1]<=(code_num_1[2]>=code_num_1[3])?3:2;
		code_idx[2]<=(code_num_1[4]>=code_num_1[5])?5:4;
		code_idx[3]<=(code_num_1[6]>=code_num_1[7])?7:6;
	 end
	 
    else if(pipe6)//��������ˮ 
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_num_tmp[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_num_tmp[3]:code_num_tmp[2];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];
		code_idx[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_idx[3]:code_idx[2];////5.86
     end 
  
    else if(pipe7)//���߼���ˮ
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];  
		code_num_tmp[1]<=(code_num_1[8]>=code_num_1[9])?code_num_1[9]:code_num_1[8];
		code_idx[1]<=(code_num_1[8]>=code_num_1[9])?9:8; 
     end 
  
    else if(pipe8)//�ڰ˼���ˮ
     code_idx[5]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0]; 
    
  end
  
  assign id0=code_idx[4];//���Ƶ����Сֵ  
  assign id1=code_idx[5];//���Ƶ�ʴ�Сֵ
  
endmodule

module HuffmanCoding(clk,rst_n,start,data_in,output_start,output_data,output_done);
  input rst_n;
  input clk;
  input start;
  input [3:0]data_in;
  output output_data;
  output output_done;
  output output_start;
 
      
   wire start_keep; 
   wire coding_sign;

     
   wire [7:0]code_r0;
   wire [7:0]code_r1;
   wire [7:0]code_r2;
   wire [7:0]code_r3;
   wire [7:0]code_r4;
   wire [7:0]code_r5;
   wire [7:0]code_r6;
   wire [7:0]code_r7;
   wire [7:0]code_r8;
   wire [7:0]code_r9;
   
   wire [3:0]id0;
   wire [3:0]id1;
   
   wire [9:0]tree0_tmp;
   wire [9:0]tree1_tmp;
   
   wire  [6:0]codehf_0;
   wire  [6:0]codehf_1;
   wire  [6:0]codehf_2;
   wire  [6:0]codehf_3;
   wire  [6:0]codehf_4;
   wire  [6:0]codehf_5;
   wire  [6:0]codehf_6;
   wire  [6:0]codehf_7;
   wire  [6:0]codehf_8;
   wire  [6:0]codehf_9;
   
   wire  [2:0]code_length_0;
   wire  [2:0]code_length_1;
   wire  [2:0]code_length_2;
   wire  [2:0]code_length_3;
   wire  [2:0]code_length_4;
   wire  [2:0]code_length_5;
   wire  [2:0]code_length_6;
   wire  [2:0]code_length_7;
   wire  [2:0]code_length_8;
   wire  [2:0]code_length_9; 
     
   wire fifo_rd; 
   wire fsm_start;
   wire [3:0]data_in_out;

 control control(.clk(clk),.rst_n(rst_n),.start(start),.start_keep(start_keep),.coding_sign(coding_sign),.fsm_start(fsm_start),.pipe1(coding_sign_delay),.pipe2(coding_sign_delay2),.pipe3(coding_sign_delay3),.pipe4(coding_sign_delay4),.pipe5(coding_sign_delay5),.pipe6(coding_sign_delay6),.pipe7(coding_sign_delay7),.pipe8(coding_sign_delay8),.refresh(coding_sign_delay9),.coding_encoder(coding_sign_tree));
 codenum codenum(.clk(clk),.rst_n(rst_n),.en_1(start_keep),.en_2(coding_sign_delay9),.data_in(data_in),.code_0(code_r0),.code_1(code_r1),.code_2(code_r2),.code_3(code_r3),.code_4(code_r4),.code_5(code_r5),.code_6(code_r6),.code_7(code_r7),.code_8(code_r8),.code_9(code_r9),.id0_r(id0),.id1_r(id1));
 selector selector(.clk(clk),.rst_n(rst_n),.coding_sign(coding_sign),.pipe1(coding_sign_delay),.pipe2(coding_sign_delay2),.pipe3(coding_sign_delay3),.pipe4(coding_sign_delay4),.pipe5(coding_sign_delay5),.pipe6(coding_sign_delay6),.pipe7(coding_sign_delay7),.pipe8(coding_sign_delay8),.code_r0(code_r0),.code_r1(code_r1),.code_r2(code_r2),.code_r3(code_r3),.code_r4(code_r4),.code_r5(code_r5),.code_r6(code_r6),.code_r7(code_r7),.code_r8(code_r8),.code_r9(code_r9),.id0(id0),.id1(id1));
 codetree codetree(.clk(clk),.rst_n(rst_n),.en(coding_sign_delay9),.vic0(id0),.vic1(id1),.tree0_tmp(tree0_tmp),.tree1_tmp(tree1_tmp));
 encoder encoder(.clk(clk),.rst_n(rst_n),.en(coding_sign_tree),.r_tree(coding_sign_delay9),.tree_r0(tree0_tmp),.tree_r1(tree1_tmp),.codehf_0(codehf_0),.codehf_1(codehf_1),.codehf_2(codehf_2),.codehf_3(codehf_3),.codehf_4(codehf_4),.codehf_5(codehf_5),.codehf_6(codehf_6),.codehf_7(codehf_7),.codehf_8(codehf_8),.codehf_9(codehf_9),.
 code_length_0(code_length_0),.code_length_1(code_length_1),.code_length_2(code_length_2),.code_length_3(code_length_3),.code_length_4(code_length_4),.code_length_5(code_length_5),.code_length_6(code_length_6),.code_length_7(code_length_7),.code_length_8(code_length_8),.code_length_9(code_length_9));
 Output Output(.clk(clk),.rst_n(rst_n),
 .codehf_r0(codehf_0),.codehf_r1(codehf_1),.codehf_r2(codehf_2),.codehf_r3(codehf_3),.codehf_r4(codehf_4),.codehf_r5(codehf_5),.codehf_r6(codehf_6),.codehf_r7(codehf_7),.codehf_r8(codehf_8),.codehf_r9(codehf_9),
 .length_r0(code_length_0),.length_r1(code_length_1),.length_r2(code_length_2),.length_r3(code_length_3),.length_r4(code_length_4),.length_r5(code_length_5),.length_r6(code_length_6),.length_r7(code_length_7),.length_r8(code_length_8),.length_r9(code_length_9),
 .output_data(output_data),.data_in(data_in_out),.output_start(output_start),.output_done(output_done),.fifo_rd(fifo_rd),.fsm_start(fsm_start));
 data_fifo data_fifo(.clk(clk),.rst(rst_n),.wr_data(data_in),.rd_data(data_in_out),.rd_en(fifo_rd),.wr_en(start_keep));
 
 endmodule
