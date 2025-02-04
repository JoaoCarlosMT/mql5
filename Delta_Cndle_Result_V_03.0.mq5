


#property script_show_inputs
#property indicator_buffers 7
#property indicator_plots 1   

#property indicator_separate_window   //Indicator in chart window              

//#property indicator_maximum    600
//#property indicator_minimum    -600

#property indicator_label1 "Open;High;Low;Close"
#property indicator_type1 DRAW_COLOR_CANDLES   //Drawing style color candles
#property indicator_width1 1       //Width of the graphic plot  

#property indicator_label2  "Lb_High_Low_Line"
#property indicator_type2  DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
     

   MqlTick tick_array_dol[];   // Tick recebendo o array
   MqlTick tick_array_wdol[]; 
  
//input string Ativo_Mini = "WDON21";
//input string Ativo_Cheio = "DOLN21";
input int vMille_Seconds = 700;
input string Ativo_Mini = "MESZ21";
input string Ativo_Cheio = "EPZ21";
input int vCheioMini=10;
//input int vCheioMini=5;//dol

input  int vxBars = 216;
int vBars = vxBars;

input bool vToday=true;


int vBars_Chart=0;//numeros barras visiveis
      
int   VchartScale = 0;
bool vChartChange = true;

int x=0;
int y=0;

input int vZip=15000;//9000*0,25(tick size)=2.250
int vArray_Size = 10000; //150000

double Delta_Cndle_Result_Array[10000];

int    Delta_Cndle_Resultado = 0;
int    Delta_Cndle_Resultado_Total = 0;
                                                                                                   
datetime vTime_StarBar=0;                                 
datetime vTime_EndBar=0;

 int i_dol=0;
 int i_wdol=0;//for

       int    Vprev_calculated = 0;
       int    Vrates_total = 0;

double tick_size =0;
int Copied_Rates_Cndle_Array = 0;

double buf_open[],buf_high[],buf_low[],buf_close[],buf_Averg_line[];//Buffers for data
double buf_color_line[];  //Buffer for color indexes


MqlRates Rates_Cndle_Array[];
MqlRates Rates_D1_Array[];

int cnt_teste=0;
void OnInit()
  {
    ChartSetInteger(0,CHART_EVENT_MOUSE_WHEEL,1);
     VchartScale = (int)ChartGetInteger(0,CHART_SCALE);

  //Assign the arrays with the indicator's buffers
   SetIndexBuffer(0,buf_open,INDICATOR_DATA);
   SetIndexBuffer(1,buf_high,INDICATOR_DATA);
   SetIndexBuffer(2,buf_low,INDICATOR_DATA);
   SetIndexBuffer(3,buf_close,INDICATOR_DATA);
   SetIndexBuffer(4,buf_color_line,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,buf_Averg_line,INDICATOR_DATA);   
   for(int i=0;i<=4;i++)PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0.0);
   

   SetIndexBuffer(6,Delta_Cndle_Result_Array,INDICATOR_CALCULATIONS); 
   
//Assign the array with color indexes with the indicator's color indexes buffer
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,2);

   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrWhite); 
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,clrBlack); 

PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,3);

//---
    ArraySetAsSeries(Rates_Cndle_Array,true);
    ArraySetAsSeries(Rates_D1_Array,true);

//---
EventSetMillisecondTimer(vMille_Seconds);       
tick_size = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE); 

ObjectsDeleteAll(0,"Lb_Cndle_Result_");
ObjectsDeleteAll(1,"Lb_Cndle_Result_");
ChartRedraw(0);


  }
  
  
    //-----------------------------------------
  
void OnTimer()
  {
  vChartChange = true;
  }
//+------------------------------------------------------------------+


  void OnDeinit(const int reason)
  {
/*
ObjectsDeleteAll(0,"Obj_Delta_Cndle_Histogram_"); 
ObjectsDeleteAll(0,"Obj_Delta_Cndle_Histogram_"); 
ObjectsDeleteAll(0,"Indic_Delta_Cndle_Histogram_");    
ObjectsDeleteAll(0,"Lab_Delta_Cndle_Profile_");
ObjectsDeleteAll(0,"Lab_Delta_Cndle_Poc");    
ObjectsDeleteAll(0,"Obj_Delta_Cndle_Poc");
ObjectsDeleteAll(0,"Cndle_Rect_");
*/
EventKillTimer();
  
  }



//+------------------------------------------------------------------+

  
  
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],              
                const int &spread[])
  {
  
  	      	
  if( prev_calculated != rates_total || (VchartScale != (int)ChartGetInteger(0,CHART_SCALE)) || (vChartChange == true)  ){

            VchartScale = (int)ChartGetInteger(0,CHART_SCALE); vChartChange = false; 
            vChartChange= false;
         
         
           vBars_Chart = ChartGetInteger(0,CHART_VISIBLE_BARS) ;
           vBars=vBars_Chart;

           Vprev_calculated = prev_calculated;
           Vrates_total = rates_total;
    //------      
 
         if( prev_calculated == 0 ||prev_calculated != rates_total  )  
         {
         if(!vToday)vTime_StarBar = time[rates_total-1-vBars_Chart];
         vTime_EndBar =  time[rates_total-2]+PeriodSeconds(); 
         
         CopyTk() ;
         }
         
         if( prev_calculated == rates_total  )  
         {
         if(!vToday)vTime_StarBar = time[rates_total-1];
         vTime_EndBar =  time[rates_total-1]+PeriodSeconds(); 
         
         CopyTk() ;
         }         
      /*     
         
         if( prev_calculated != rates_total  && prev_calculated > 0) 
         { vTime_StarBar = time[rates_total-1-vBars_Chart];     
         vTime_EndBar =  time[rates_total-2] ;
         }
         
        
         if( prev_calculated == rates_total)
         {  vTime_StarBar = time[rates_total-1];
          vTime_EndBar =  time[rates_total-1]+PeriodSeconds();  
          //Print(prev_calculated);
          }         
     */
    
      }//end  prev_calculated == 0 || prev_calculated != rates_total   
   

   return(rates_total);
  }  

//+------------------------------------------------------------------+  
  
  void CopyTk(){
  
     
         Copied_Rates_Cndle_Array = CopyRates(_Symbol,_Period,0, vBars_Chart, Rates_Cndle_Array );// PERIOD_M1   zero (atual)  ArraySetAsSeries(Rates_Cndle_Array,true);
            
         datetime Open_BarTime = vTime_StarBar;
          
         MqlDateTime StartPeriod_Array;
         datetime current_time=Open_BarTime ;
         if(!vToday){
         current_time=Open_BarTime ; //TimeCurrent();                         
         TimeToStruct(current_time,StartPeriod_Array);                            
         }else{
         TimeToStruct(TimeCurrent(),StartPeriod_Array);                            
         string Vy = StartPeriod_Array.year; 
         string Vm = StartPeriod_Array.mon; 
         string Vd= StartPeriod_Array.day;
         string Vh = StartPeriod_Array.hour;
         string Vmn = StartPeriod_Array.min;                     
         string Vs = StartPeriod_Array.sec;
         datetime vHj = StringToTime(Vy+"."+Vm+"."+Vd+" 09:00:00");       
         //StringToTime("2012.12.05 22:31:57");         
         TimeToStruct(vHj,StartPeriod_Array);
         
         }      
        
        
         MqlDateTime EndPeriod_Array;
         datetime current_time1=vTime_EndBar;                           
         TimeToStruct(current_time1,EndPeriod_Array);                            
      
         datetime startday=StructToTime(StartPeriod_Array);//
         datetime endday=StructToTime(EndPeriod_Array); //startday+24*60*60;
            

        if((CopyTicksRange(Ativo_Cheio,tick_array_dol,COPY_TICKS_ALL,startday*1000,endday*1000))<=0){
        PrintFormat("CopyTicksRange(%s,tick_array,COPY_TICKS_ALL,%s,%s) failed, error %d",  _Symbol,TimeToString(startday),TimeToString(endday),GetLastError());                                                                                             
        }  else{
       
       if((CopyTicksRange(Ativo_Mini,tick_array_wdol,COPY_TICKS_ALL,startday*1000,endday*1000))<=0) 
         {
         PrintFormat("CopyTicksRange(%s,tick_array,COPY_TICKS_ALL,%s,%s) failed, error %d", _Symbol,TimeToString(startday),TimeToString(endday),GetLastError());          
         }  else{           
           
           
     //---------      

           if(Copied_Rates_Cndle_Array >0    ) Chart_Draw_void(Vprev_calculated ,Vrates_total);
            
            
           //  ChartRedraw(0);  
             
         }} //end else
  
  
  
  }
  
//+------------------------------------------------------------------+  
  
  void Chart_Draw_void(int Vprev_calculated , int Vrates_total){
  
 //  if(Vprev_calculated == Vrates_total )vBars=1;
 
  i_dol=0;
  i_wdol=0;
  for(int i_H1=vBars-1; i_H1 >=0; i_H1--) // zero (atual) 
    {    
    
 
     
       datetime  vTime_Start = Rates_Cndle_Array[i_H1].time;//
       datetime  vTime_End =  Rates_Cndle_Array[i_H1].time+PeriodSeconds();   //0
  
   VchartScale = (int)ChartGetInteger(0,CHART_SCALE); vChartChange = false;
  

   //reset array
   
    Delta_Cndle_Resultado = 0;
    ArrayFree(Delta_Cndle_Result_Array);
    ArrayResize(Delta_Cndle_Result_Array,vArray_Size);
    ArrayInitialize(Delta_Cndle_Result_Array,0);
      
  
                  
       for ( i_dol; i_dol<ArraySize(tick_array_dol); i_dol++)
           {
           
           if(tick_array_dol[i_dol].time > vTime_End )break;
           
       if((tick_array_dol[i_dol].last)!=0 && (tick_array_dol[i_dol].volume)!=0 &&
         ((tick_array_dol[i_dol].flags&TICK_FLAG_BUY)!=0 && (tick_array_dol[i_dol].flags&TICK_FLAG_SELL)==0) ||
         ((tick_array_dol[i_dol].flags&TICK_FLAG_ASK)!=0 && (tick_array_dol[i_dol].flags&TICK_FLAG_BID)==0) 
         )
         {
         
         
         int Vdx = int((tick_array_dol[i_dol].last/tick_size)-vZip); ///tick_size
        if(Vdx>0)   Delta_Cndle_Result_Array[Vdx]=Delta_Cndle_Result_Array[Vdx]+int(tick_array_dol[i_dol].volume*vCheioMini);
        if(Vdx>0 ) Delta_Cndle_Resultado +=  int(tick_array_dol[i_dol].volume*vCheioMini);  
                       }
              
       if((tick_array_dol[i_dol].last)!=0 && (tick_array_dol[i_dol].volume)!=0 &&
       ((tick_array_dol[i_dol].flags&TICK_FLAG_BUY)==0 && (tick_array_dol[i_dol].flags&TICK_FLAG_SELL)!=0) ||
       ((tick_array_dol[i_dol].flags&TICK_FLAG_ASK)==0 && (tick_array_dol[i_dol].flags&TICK_FLAG_BID)!=0) 
       )       
       {
         int Vdx = int((tick_array_dol[i_dol].last/tick_size)-vZip);
       if(Vdx>0)  Delta_Cndle_Result_Array[Vdx]=Delta_Cndle_Result_Array[Vdx]-int(tick_array_dol[i_dol].volume*vCheioMini);
        if(Vdx>0 ) Delta_Cndle_Resultado -=  int(tick_array_dol[i_dol].volume*vCheioMini);  
                       }
               
       if((tick_array_dol[i_dol].last)!=0 && (tick_array_dol[i_dol].volume)!=0 &&
       ((tick_array_dol[i_dol].flags&TICK_FLAG_BUY)!=0 && (tick_array_dol[i_dol].flags&TICK_FLAG_SELL)!=0) ||
       ((tick_array_dol[i_dol].flags&TICK_FLAG_ASK)!=0 && (tick_array_dol[i_dol].flags&TICK_FLAG_BID)!=0) 
       )
       {
 
         int Vdx = int((tick_array_dol[i_dol].last/tick_size)-vZip);     
       if( Vdx>0 ) { 
       if( Delta_Cndle_Result_Array[Vdx]>=0  && Vdx>0 ){
        Delta_Cndle_Result_Array[Vdx]  =  Delta_Cndle_Result_Array[Vdx] + int(tick_array_dol[i_dol].volume*vCheioMini);
        if(Vdx>0 ) Delta_Cndle_Resultado +=  int(tick_array_dol[i_dol].volume*vCheioMini);  
       }
       if( Delta_Cndle_Result_Array[Vdx]<0  && Vdx>0 ) {
       Delta_Cndle_Result_Array[Vdx]  =  Delta_Cndle_Result_Array[Vdx] - int(tick_array_dol[i_dol].volume*vCheioMini);
       if(Vdx>0 ) Delta_Cndle_Resultado -=  int(tick_array_dol[i_dol].volume*vCheioMini);  
       }
        }                         
          }
          
     // if(i_dol == ArraySize(tick_array_dol)-1 ) break;       
                    }//end For
               


     //--- .volume_real          
     //-----------------------------------------------------------------------------            
                 

       for (i_wdol; i_wdol<ArraySize(tick_array_wdol); i_wdol++)
         {
    
        if(tick_array_wdol[i_wdol].time > vTime_End ) break;      
        
       if((tick_array_wdol[i_wdol].last)!=0 && (tick_array_wdol[i_wdol].volume)!=0 &&
       ((tick_array_wdol[i_wdol].flags&TICK_FLAG_BUY)!=0 && (tick_array_wdol[i_wdol].flags&TICK_FLAG_SELL)==0) ||
       ((tick_array_wdol[i_wdol].flags&TICK_FLAG_ASK)!=0 && (tick_array_wdol[i_wdol].flags&TICK_FLAG_BID)==0)
       )
       {
        
         int Vdx = int((tick_array_wdol[i_wdol].last/tick_size)-vZip);
        if(Vdx>0)  Delta_Cndle_Result_Array[Vdx]=Delta_Cndle_Result_Array[Vdx]+int(tick_array_wdol[i_wdol].volume);
        if(Vdx>0 ) Delta_Cndle_Resultado +=  int(tick_array_wdol[i_wdol].volume);   
                    }
                    
       if((tick_array_wdol[i_wdol].last)!=0 && (tick_array_wdol[i_wdol].volume)!=0 &&
       ((tick_array_wdol[i_wdol].flags&TICK_FLAG_BUY)==0 && (tick_array_wdol[i_wdol].flags&TICK_FLAG_SELL)!=0) ||
       ((tick_array_wdol[i_wdol].flags&TICK_FLAG_ASK)==0 && (tick_array_wdol[i_wdol].flags&TICK_FLAG_BID)!=0)
       )
       {
         int Vdx = int((tick_array_wdol[i_wdol].last/tick_size)-vZip);
        if(Vdx>0)  Delta_Cndle_Result_Array[Vdx]=Delta_Cndle_Result_Array[Vdx]-int(tick_array_wdol[i_wdol].volume);                  
        if(Vdx>0 ) Delta_Cndle_Resultado -=  int(tick_array_wdol[i_wdol].volume);             
                    }
        if((tick_array_wdol[i_wdol].last)!=0 && (tick_array_wdol[i_wdol].volume)!=0 &&
        ((tick_array_wdol[i_wdol].flags&TICK_FLAG_BUY)!=0 && (tick_array_wdol[i_wdol].flags&TICK_FLAG_SELL)!=0) ||
        ((tick_array_wdol[i_wdol].flags&TICK_FLAG_ASK)!=0 && (tick_array_wdol[i_wdol].flags&TICK_FLAG_BID)!=0)
        )
        {
        
 
          int Vdx = int((tick_array_wdol[i_wdol].last/tick_size)-vZip);
        if( Vdx>0) {
        if( Delta_Cndle_Result_Array[Vdx]>=0  && Vdx>0){
         Delta_Cndle_Result_Array[Vdx]  =  Delta_Cndle_Result_Array[Vdx] + int(tick_array_wdol[i_wdol].volume);
         if(Vdx>0 ) Delta_Cndle_Resultado +=  int(tick_array_wdol[i_wdol].volume);   
         }
        if( Delta_Cndle_Result_Array[Vdx]<0  && Vdx>0) {
        Delta_Cndle_Result_Array[Vdx]  =  Delta_Cndle_Result_Array[Vdx] - int(tick_array_wdol[i_wdol].volume);
        if(Vdx>0 ) Delta_Cndle_Resultado -=  int(tick_array_wdol[i_wdol].volume);   
        }
          }
          }
          
     //   if(i_wdol == ArraySize(tick_array_wdol)-1 ) break;

                    }//end for

/*
  //------------------------------------------------------
   int height=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int width=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   datetime      vtime=0;         // Tempo no gráfico
   double        vprice_Y=0; 
   int vwind=0;      
   ChartXYToTimePrice(  0,  1,       height,  vwind   ,   vtime,        vprice_Y     );
//---------------------------------------------------

*/
 
     //Set data for plotting
  
      int i1=Vrates_total-1-i_H1;  

   int vMultiplo = 1;
        
  
  // if(vBars!=1 && (i_H1 >= 0)){
if(Vprev_calculated != Vrates_total || Vprev_calculated == 0 )  {
      buf_open[i1]=Delta_Cndle_Resultado_Total/vMultiplo;      

      Delta_Cndle_Resultado_Total +=Delta_Cndle_Resultado;
      
       buf_close[i1]=0;buf_low[i1]=0;buf_high[i1]=0;  
       buf_close[i1]=Delta_Cndle_Resultado_Total/vMultiplo;           
 
      if( buf_close[i1]> buf_open[i1]){ //branco
       buf_low[i1]=buf_open[i1];
       buf_high[i1]=Delta_Cndle_Resultado_Total/vMultiplo;  
     //  buf_Averg_line[i1]=(buf_high[i1]);     
      }
      if( buf_close[i1]< buf_open[i1]){ //preto
       buf_high[i1]=buf_open[i1];
       buf_low[i1]=Delta_Cndle_Resultado_Total/vMultiplo;     
    //   buf_Averg_line[i1]=(buf_low[i1]);   
      }      
      
 } 
 
 
//if(Vprev_calculated == Vrates_total  && vBars==1 ){
if(Vprev_calculated == Vrates_total ){
   // Print(TimeCurrent());
    i1=Vrates_total-1;
 buf_open[i1]=buf_close[i1-1];


     int vSubTotal = buf_close[i1-1] +Delta_Cndle_Resultado;
      // Print(vSubTotal);
       //buf_close[i1]=0;buf_low[i1]=0;buf_high[i1]=0;  
     
      if( vSubTotal > buf_open[i1]){
       buf_low[i1]=buf_open[i1];
       buf_high[i1]=vSubTotal/vMultiplo; 
       buf_close[i1]=vSubTotal/vMultiplo;
     //  buf_Averg_line[i1]=(buf_high[i1]);    
      }
      if( vSubTotal< buf_open[i1]){
       buf_high[i1]=buf_open[i1];
       buf_low[i1]=vSubTotal/vMultiplo; 
       buf_close[i1]=vSubTotal/vMultiplo; 
   //    buf_Averg_line[i1]=(buf_low[i1]);    
      } 
      

}  


 
  
  //Print(i1,"   ",buf_open[i1],"   ",buf_low[i1],"   ",buf_close[i1]);
  
      if(Delta_Cndle_Resultado < 0) buf_color_line[i1]=1;//Black
      if(Delta_Cndle_Resultado >= 0) buf_color_line[i1]=0;//white
    
      // }  //end        if((CopyTicksRange(Ativo_Mini,tick_array_wdol,COPY_TICKS_ALL,startday*1000,endday*1000))==-1)     
      // } //end  if((CopyTicksRange(Ativo_Cheio,tick_array_dol,COPY_TICKS_ALL,startday*1000,endday*1000))>0)
  } //end   for(int i_H1=vBars-1; i_H1 >=0; i_H1--) // zero (atual) 

  
  }//end on calculate

//-----------------------------------------------------------------

void VLine_Obj(string VLine_Name, datetime Pos_datetime , int BookLineWidth , double Line_Style,double Label_Color ) {
      ObjectCreate(_Symbol,VLine_Name,OBJ_VLINE,0,Pos_datetime,0);
      ObjectSetInteger(0,VLine_Name,OBJPROP_COLOR,Label_Color);     
      ObjectSetInteger(0,VLine_Name,OBJPROP_STYLE,Line_Style);
       ObjectSetInteger(0,VLine_Name,OBJPROP_WIDTH,BookLineWidth);
      ObjectSetInteger(0,VLine_Name,OBJPROP_SELECTABLE,true);
       ObjectSetInteger(0,VLine_Name,OBJPROP_BACK,true);
      ObjectSetInteger(0,VLine_Name,OBJPROP_RAY,true);

}
//-----------------------------------------------------------------

  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

  
     switch(id)
     {
        case CHARTEVENT_CHART_CHANGE :{
       // vChartChange = true;
              ChartRedraw(0);
        if(VchartScale != (int)ChartGetInteger(0,CHART_SCALE)){ ChartRedraw(0); 
        VchartScale = (int)ChartGetInteger(0,CHART_SCALE);}
       break;
        
        }
        case CHARTEVENT_MOUSE_WHEEL :{
      //  vChartChange = true;
        ChartRedraw(0);
        
       // if(VchartScale != (int)ChartGetInteger(0,CHART_SCALE)) 
   //    Print("mause while");
       break;
        
        }        
        
        
     }
  }
  
 //-----------------------------------------------
 


 void Label_General(int wndow, string Label_ID,string Label_TX,int Label_Corner, int Label_X,int Label_Y,double Label_Color, int FontSize)
{
  
      ObjectCreate(_Symbol,Label_ID,OBJ_LABEL,wndow,0,0);
      ObjectSetInteger(0,Label_ID,OBJPROP_COLOR,Label_Color);  
      ObjectSetInteger(0,Label_ID,OBJPROP_CORNER,Label_Corner);
      ObjectSetInteger(0,Label_ID,OBJPROP_XDISTANCE,Label_X); 
      ObjectSetInteger(0,Label_ID,OBJPROP_YDISTANCE,Label_Y); 
      ObjectSetString(0,Label_ID,OBJPROP_FONT,"Arial Black"); 
      ObjectSetString(0,Label_ID,OBJPROP_TEXT,Label_TX); 
      ObjectSetInteger(0,Label_ID,OBJPROP_FONTSIZE,FontSize); 
      ObjectSetInteger(0,Label_ID,OBJPROP_SELECTABLE,true); 
      ObjectSetInteger(0,Label_ID,OBJPROP_ANCHOR,ANCHOR_CENTER); 
      
       //ObjectSetInteger(0,Label_ID,OBJPROP_BACK,true );    
}
//-------------------------------------------------------------------
 void Label_FontName(int wndow, string Label_ID,string Label_TX,int Label_Corner, int Label_X,int Label_Y,string Font_Name,double Label_Color, int FontSize)
{
  
      ObjectCreate(_Symbol,Label_ID,OBJ_LABEL,wndow,0,0);
      ObjectSetInteger(0,Label_ID,OBJPROP_COLOR,Label_Color);  
      ObjectSetInteger(0,Label_ID,OBJPROP_CORNER,Label_Corner);
      ObjectSetInteger(0,Label_ID,OBJPROP_XDISTANCE,Label_X); 
      ObjectSetInteger(0,Label_ID,OBJPROP_YDISTANCE,Label_Y); 
      ObjectSetString(0,Label_ID,OBJPROP_FONT,Font_Name); 
      ObjectSetString(0,Label_ID,OBJPROP_TEXT,Label_TX); 
      ObjectSetInteger(0,Label_ID,OBJPROP_FONTSIZE,FontSize); 
      ObjectSetInteger(0,Label_ID,OBJPROP_SELECTABLE,true); 
       ObjectSetInteger(0,Label_ID,OBJPROP_BACK,true );    
}

  //-----------------------------------------------------------------------------------
//+------------------------------------------------------------------+
void Cndle_Rect_angle_Obj(int chart_id, string Name,int sub_Window, datetime Hiest_Time,double  Hiest_Price,datetime Lowest_Time,double  Lowest_Price,ENUM_LINE_STYLE style_Line ,double Label_Color, int LineWidth ){
        ObjectDelete(0,Name); 
        ObjectCreate(ChartID(),Name,OBJ_RECTANGLE,sub_Window,Hiest_Time , Hiest_Price, Lowest_Time ,Lowest_Price );   
        ObjectSetInteger(ChartID(),Name,OBJPROP_COLOR,Label_Color);   
        ObjectSetInteger(ChartID(),Name,OBJPROP_STYLE,style_Line);   
        ObjectSetInteger(ChartID(),Name,OBJPROP_WIDTH,LineWidth);                               //
        ObjectSetInteger(ChartID(),Name,OBJPROP_FILL, false);
        ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE, true);
        ObjectSetInteger(ChartID(),Name,OBJPROP_BACK, true);
 }
 
 //--------------------------
 
 void Screen_Shot(string FileName){

int WIDTH=2560;
int HEIGHT=1080;

 int Xmrg=650;
 int ymrg=0;
 int fnt=11; 
 int vCnt=0;
//string vFile = "screenShot.jpg";
               //--- Salvar a captura de tela do gráfico em um arquivo no terminal_directory\MQL5\Files\
            if(ChartScreenShot(0,FileName,WIDTH,HEIGHT,ALIGN_LEFT)){  }
        //    vCnt++;
 // Label_FontName(0,"Lbl_indc_ScreenShot","Screen Shot "+vCnt, 3 , Xmrg ,ymrg ,"Arial Black",clrSteelBlue, fnt);   //branco slow
         

}

//-----------------------------------------------