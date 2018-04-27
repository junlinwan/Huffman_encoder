`timescale 1ns / 1ps

module top(
    input clk, rst, mode,
    output [10:0]display_out
//    output output_data, output_start
    );


reg  [3:0]data_in;
reg  [11:0]counter=0;
wire start, output_done;
wire rst_n = !rst;


always@(posedge clk)
 begin
  if(counter<2048&&mode==1)
    counter<=counter+1;
  else
    counter <= counter;
 end

assign  start=(counter==5)?1:0;

always@(*)
  begin
  case(counter)
6   :data_in=   5   ;
7   :data_in=   3   ;
8   :data_in=   6   ;
9   :data_in=   5   ;
10  :data_in=   0   ;
11  :data_in=   7   ;
12  :data_in=   8   ;
13  :data_in=   3   ;
14  :data_in=   5   ;
15  :data_in=   1   ;
16  :data_in=   8   ;
17  :data_in=   4   ;
18  :data_in=   6   ;
19  :data_in=   6   ;
20  :data_in=   0   ;
21  :data_in=   0   ;
22  :data_in=   3   ;
23  :data_in=   5   ;
24  :data_in=   3   ;
25  :data_in=   3   ;
26  :data_in=   1   ;
27  :data_in=   7   ;
28  :data_in=   8   ;
29  :data_in=   1   ;
30  :data_in=   9   ;
31  :data_in=   7   ;
32  :data_in=   9   ;
33  :data_in=   2   ;
34  :data_in=   1   ;
35  :data_in=   8   ;
36  :data_in=   3   ;
37  :data_in=   9   ;
38  :data_in=   4   ;
39  :data_in=   8   ;
40  :data_in=   9   ;
41  :data_in=   4   ;
42  :data_in=   6   ;
43  :data_in=   6   ;
44  :data_in=   4   ;
45  :data_in=   0   ;
46  :data_in=   5   ;
47  :data_in=   8   ;
48  :data_in=   6   ;
49  :data_in=   6   ;
50  :data_in=   2   ;
51  :data_in=   7   ;
52  :data_in=   3   ;
53  :data_in=   4   ;
54  :data_in=   4   ;
55  :data_in=   9   ;
56  :data_in=   6   ;
57  :data_in=   4   ;
58  :data_in=   1   ;
59  :data_in=   8   ;
60  :data_in=   0   ;
61  :data_in=   4   ;
62  :data_in=   3   ;
63  :data_in=   3   ;
64  :data_in=   6   ;
65  :data_in=   9   ;
66  :data_in=   1   ;
67  :data_in=   5   ;
68  :data_in=   2   ;
69  :data_in=   6   ;
70  :data_in=   3   ;
71  :data_in=   0   ;
72  :data_in=   5   ;
73  :data_in=   3   ;
74  :data_in=   6   ;
75  :data_in=   3   ;
76  :data_in=   2   ;
77  :data_in=   2   ;
78  :data_in=   8   ;
79  :data_in=   3   ;
80  :data_in=   3   ;
81  :data_in=   9   ;
82  :data_in=   5   ;
83  :data_in=   1   ;
84  :data_in=   4   ;
85  :data_in=   8   ;
86  :data_in=   2   ;
87  :data_in=   8   ;
88  :data_in=   6   ;
89  :data_in=   6   ;
90  :data_in=   1   ;
91  :data_in=   2   ;
92  :data_in=   9   ;
93  :data_in=   0   ;
94  :data_in=   6   ;
95  :data_in=   8   ;
96  :data_in=   2   ;
97  :data_in=   4   ;
98  :data_in=   2   ;
99  :data_in=   1   ;
100 :data_in=   7   ;
101 :data_in=   8   ;
102 :data_in=   7   ;
103 :data_in=   9   ;
104 :data_in=   9   ;
105 :data_in=   3   ;
106 :data_in=   2   ;
107 :data_in=   7   ;
108 :data_in=   2   ;
109 :data_in=   0   ;
110 :data_in=   9   ;
111 :data_in=   8   ;
112 :data_in=   0   ;
113 :data_in=   0   ;
114 :data_in=   7   ;
115 :data_in=   2   ;
116 :data_in=   0   ;
117 :data_in=   1   ;
118 :data_in=   5   ;
119 :data_in=   6   ;
120 :data_in=   6   ;
121 :data_in=   4   ;
122 :data_in=   7   ;
123 :data_in=   3   ;
124 :data_in=   6   ;
125 :data_in=   5   ;
126 :data_in=   0   ;
127 :data_in=   3   ;
128 :data_in=   3   ;
129 :data_in=   4   ;
130 :data_in=   6   ;
131 :data_in=   2   ;
132 :data_in=   0   ;
133 :data_in=   0   ;
134 :data_in=   3   ;
135 :data_in=   3   ;
136 :data_in=   1   ;
137 :data_in=   6   ;
138 :data_in=   4   ;
139 :data_in=   8   ;
140 :data_in=   3   ;
141 :data_in=   7   ;
142 :data_in=   5   ;
143 :data_in=   9   ;
144 :data_in=   5   ;
145 :data_in=   5   ;
146 :data_in=   9   ;
147 :data_in=   0   ;
148 :data_in=   9   ;
149 :data_in=   3   ;
150 :data_in=   3   ;
151 :data_in=   3   ;
152 :data_in=   4   ;
153 :data_in=   4   ;
154 :data_in=   5   ;
155 :data_in=   7   ;
156 :data_in=   0   ;
157 :data_in=   1   ;
158 :data_in=   0   ;
159 :data_in=   3   ;
160 :data_in=   2   ;
161 :data_in=   6   ;
162 :data_in=   5   ;
163 :data_in=   8   ;
164 :data_in=   7   ;
165 :data_in=   1   ;
166 :data_in=   5   ;
167 :data_in=   6   ;
168 :data_in=   8   ;
169 :data_in=   0   ;
170 :data_in=   2   ;
171 :data_in=   0   ;
172 :data_in=   4   ;
173 :data_in=   5   ;
174 :data_in=   8   ;
175 :data_in=   2   ;
176 :data_in=   5   ;
177 :data_in=   3   ;
178 :data_in=   1   ;
179 :data_in=   4   ;
180 :data_in=   1   ;
181 :data_in=   6   ;
182 :data_in=   0   ;
183 :data_in=   9   ;
184 :data_in=   6   ;
185 :data_in=   3   ;
186 :data_in=   7   ;
187 :data_in=   6   ;
188 :data_in=   2   ;
189 :data_in=   8   ;
190 :data_in=   6   ;
191 :data_in=   5   ;
192 :data_in=   6   ;
193 :data_in=   8   ;
194 :data_in=   8   ;
195 :data_in=   0   ;
196 :data_in=   2   ;
197 :data_in=   8   ;
198 :data_in=   8   ;
199 :data_in=   1   ;
200 :data_in=   5   ;
201 :data_in=   9   ;
202 :data_in=   3   ;
203 :data_in=   0   ;
204 :data_in=   0   ;
205 :data_in=   8   ;
206 :data_in=   6   ;
207 :data_in=   2   ;
208 :data_in=   1   ;
209 :data_in=   0   ;
210 :data_in=   4   ;
211 :data_in=   9   ;
212 :data_in=   8   ;
213 :data_in=   7   ;
214 :data_in=   4   ;
215 :data_in=   1   ;
216 :data_in=   3   ;
217 :data_in=   7   ;
218 :data_in=   7   ;
219 :data_in=   2   ;
220 :data_in=   6   ;
221 :data_in=   7   ;
222 :data_in=   0   ;
223 :data_in=   1   ;
224 :data_in=   0   ;
225 :data_in=   7   ;
226 :data_in=   4   ;
227 :data_in=   5   ;
228 :data_in=   3   ;
229 :data_in=   1   ;
230 :data_in=   4   ;
231 :data_in=   0   ;
232 :data_in=   0   ;
233 :data_in=   4   ;
234 :data_in=   7   ;
235 :data_in=   8   ;
236 :data_in=   3   ;
237 :data_in=   7   ;
238 :data_in=   9   ;
239 :data_in=   0   ;
240 :data_in=   1   ;
241 :data_in=   5   ;
242 :data_in=   5   ;
243 :data_in=   0   ;
244 :data_in=   2   ;
245 :data_in=   0   ;
246 :data_in=   0   ;
247 :data_in=   3   ;
248 :data_in=   6   ;
249 :data_in=   2   ;
250 :data_in=   8   ;
251 :data_in=   1   ;
252 :data_in=   7   ;
253 :data_in=   7   ;
254 :data_in=   1   ;
255 :data_in=   0   ;
256 :data_in=   5   ;
257 :data_in=   2   ;
258 :data_in=   2   ;
259 :data_in=   1   ;
260 :data_in=   8   ;
261 :data_in=   5   ;


  default:;
  endcase
end






  totalcycle TC(clk, rst, start, output_done, display_out);
wire output_data, output_start;
  HuffmanCoding HF(clk,rst_n,start,data_in,output_start,output_data,output_done);

  ila_output ila_Out(.clk(clk), .probe0(output_data), .probe1(output_start), .probe2(output_done));
endmodule
