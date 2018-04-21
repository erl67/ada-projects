-- File name    : waypoints.ads
-- Purpose      : Project 2 Final Submission Waypoints Specification
-- Author       : erl
-- Course       : CS301
-- Hour/section : G4

package Waypoints is

   type Threat_Code is 
         (Unknown, 
          Green,   
          Amber,   
          Red); 

   type File_Control is --used for paths.txt I/O
         (Beginpath,  
          Beginpoint, 
          Endpoint,   
          Endpath); 

   subtype Name_String is String (1 .. 10); --name of waypoint

   subtype Map_Range is Integer range 100..999;  --range of map coordinates

   subtype Choice is Positive range 1..2;   --which point search type

   type Waypoint; 
   type Way_Ptr is access Waypoint; 

   type Waypoint is 
      record 
         Xcor : Map_Range := Map_Range'First;  
         Ycor : Map_Range := Map_Range'First;  
         Next : Way_Ptr   := null;  
      end record; 

   type Map_Point is 
      record 
         Name         : Name_String := (others => ' ');  
         Threat_Level : Threat_Code := Unknown;  
      end record; 

   type Maparray is array (Map_Range, Map_Range) of Map_Point; 
   Map : Maparray;  

   type Headarray is array (1 .. 8) of Way_Ptr; 
   Head : Headarray := (others => null);  

   function Get_A_Coord (
         Xory : in     Choice ) 
     return Map_Range; 

   function Enter_Data_Type return Choice; 

   function Enter_Threat_Code return Threat_Code; 

   function Enter_Waypoint_Name return Name_String; 

   procedure Find_Coordinates (
         Map      : in     Maparray;    
         Instring : in out Name_String; 
         Xcor,                          
         Ycor     :    out Map_Range    ); 

   procedure Enter_Data (
         Map      : in     Maparray;   
         Xcor,                         
         Ycor     :    out Map_Range;  
         Instring :    out Name_String ); 

   procedure Create_New_Path (
         Head : in out Headarray; 
         Map  : in out Maparray   ); 

   procedure Shortest_Path (
         Head : in     Headarray; 
         Map  : in     Maparray   ); 

   procedure Safest_Path (
         Head : in     Headarray; 
         Map  : in     Maparray   ); 

   procedure Add_Waypoint (
         Map  : in out Maparray; 
         Head : in out Headarray ); 

   procedure Remove_Waypoint (
         Head : in out Headarray; 
         Map  : in out Maparray   ); 

   procedure Change_Threat_Code (
         Head : in     Headarray; 
         Map  : in out Maparray   ); 

   procedure Print_Paths (
         Head : in     Headarray; 
         Map  : in     Maparray   ); 

   procedure Load_Paths (
         Head :    out Headarray; 
         Map  :    out Maparray   ); 

   procedure Save_Paths (
         Head : in     Headarray; 
         Map  : in     Maparray   ); 

end Waypoints;
