-- File name    : waypoints.adb
-- Purpose      : Project 2 Final Submission Waypoints File
-- Author       : erl
-- Course       : CS301
-- Hour/section : G4

with Ada.Text_Io, Ada.Integer_Text_Io, Ada.Float_Text_Io,
   Unchecked_Deallocation;
with Ada.Numerics.Elementary_Functions;
use Ada.Text_Io, Ada.Integer_Text_Io, Ada.Float_Text_Io;

package body Waypoints is

   package Threat_Code_Io is new Enumeration_Io(Threat_Code);
   use Threat_Code_Io;

   package File_Control_Io is new Enumeration_Io(File_Control);
   use File_Control_Io;

   procedure Dispose is 
   new Unchecked_Deallocation (Waypoint, Way_Ptr);



   --function to get one coordinate from user
   function Get_A_Coord (
         Xory : in     Choice ) 
     return Map_Range is 
      Coord : Map_Range := 100;  
   begin

      loop
         begin
            case Xory is
               when 1 =>
                  Put("Enter the X coordinate: ");
               when 2=>
                  Put("Enter the Y coordinate: ");
               when others =>
                  null;
            end case;
            Ada.Integer_Text_Io.Get(Coord);
            exit;
         exception
            when Constraint_Error | Data_Error =>
               --if input is outside Map_Range
               Skip_Line;
               New_Line;
               Put_Line("ERROR: That input was no good. Use 100-999.");
         end;
      end loop;

      return Coord;

   end Get_A_Coord;

   --function where user decides how to enter data for further operations
   function Enter_Data_Type return Choice is 
      Input_Choice : Choice := 1;  
   begin

      loop -- determine how the user will enter  a point
         begin
            New_Line;
            Put_Line("How will you enter your data?");
            Put_Line("  1.  Coordinates");
            Put_Line("  2.  Name");
            Ada.Integer_Text_Io.Get(Input_Choice);
            New_Line;
            exit;
         exception
            when Constraint_Error | Data_Error =>
               Skip_Line;
               New_Line;
               Put_Line(
                  "ERROR: That choice was no good. Try again with 1 or 2.");
         end;
      end loop;

      return Input_Choice;

   end Enter_Data_Type;

   --function for user to input threat level
   function Enter_Threat_Code return Threat_Code is 
      Threat_Input : Threat_Code := Unknown;  
   begin

      loop
         begin
            Put("Enter the threat code: ");
            Get(Threat_Input);
            exit;
         exception
            when Constraint_Error | Data_Error =>
               Skip_Line;
               New_Line;
               Put(
                  "ERROR: That input was no good. Try again with UNKNOWN,");
               Put_Line("GREEN, AMBER, or RED");
         end;
      end loop;

      return Threat_Input;

   end Enter_Threat_Code;

   --function for user to enter a waypoint name
   function Enter_Waypoint_Name return Name_String is 
      Instring : Name_String := (others => ' ');  
      Lastchar : Integer;  
   begin

      loop
         begin
            Put("Enter the name of the waypoint: ");
            Ada.Text_Io.Get_Line(Instring,Lastchar);
            exit;
         exception
            when Constraint_Error | Data_Error =>
               Skip_Line;
               New_Line;
               Put_Line("ERROR: That input was no good. Try again.");
         end;
      end loop;

      return Instring;

   end Enter_Waypoint_Name;

   --procedure that finds the Coordinates of a waypoint given the name
   procedure Find_Coordinates (
         Map      : in     Maparray;    
         Instring : in out Name_String; 
         Xcor,                          
         Ycor     :    out Map_Range    ) is 
   begin

      for I in 100..999 loop       --look through all points for name
         for J in 100..999 loop
            if Map(I,J).Name = Instring then
               Xcor := I;
               Ycor := J;
               exit;
            elsif I = 999 and J = 999 then
               Instring := "          ";
            end if;
         end loop;
         if Map(I,Ycor).Name = Instring then
            exit;
         end if;
      end loop;

   end Find_Coordinates;


   --procedure that gets users data(name or coords.) and finds whats not given
   procedure Enter_Data (
         Map      : in     Maparray;   
         Xcor,                         
         Ycor     :    out Map_Range;  
         Instring :    out Name_String ) is 

      K : Choice := 1;  

   begin
      K := Enter_Data_Type; --determine how user wants to enter data
      case K is
         when 1 =>  --user wants to search by coordinate
            Xcor := Get_A_Coord(1);
            Ycor := Get_A_Coord(2);
            Instring := Map(Xcor,Ycor).Name;
         when 2=>     --user wants to search by waypoint name
            Skip_Line;
            Instring:=Enter_Waypoint_Name;
            Find_Coordinates(Map,Instring,Xcor,Ycor);
      end case;

   end Enter_Data;

   -----------------------------------------------------------------
   -- Allows user to create a new path up to maximum of 8 paths.
   --
   --
   --            --------
   --  Map----->|        |----> Map
   --  Head---->| Create |----> Head
   --           | New    |
   --           | Path   |
   --            --------
   -----------------------------------------------------------------
   procedure Create_New_Path (
         Head : in out Headarray; 
         Map  : in out Maparray   ) is 

      I           : Integer     := 1;  
      Current_Ptr : Way_Ptr;  
      Another     : Character   := 'y';  
      Instring    : Name_String;  

   begin

      while Head(I) /=null and I < 9 loop  --find first head to start with
         I := I +1;
      end loop;
      Head(I) := new Waypoint;
      Current_Ptr:=Head(I);

      while Another = 'y' loop        --user enters data and assigns it to waypoints
         Skip_Line;
         Instring := Enter_Waypoint_Name;
         Current_Ptr.Xcor := Get_A_Coord(1);
         Current_Ptr.Ycor := Get_A_Coord(2);
         Map(Current_Ptr.Xcor,Current_Ptr.Ycor).Name:=Instring;
         Map(Current_Ptr.Xcor,Current_Ptr.Ycor).Threat_Level:=
            Enter_Threat_Code;

         Put("Enter another waypoint (y/n)? ");
         Get(Another);
         if Another = 'y' then
            Current_Ptr.Next := new Waypoint;
            Current_Ptr := Current_Ptr.Next;
         end if;
      end loop;

   end Create_New_Path;


   -----------------------------------------------------------------
   -- Calculates shortest path between a coordinate or name of a
   -- waypoint from any depot
   --
   --            --------
   --  Map----->|        |
   --  Head---->| Short  |
   --           | est    |
   --           | Path   |
   --            --------
   -----------------------------------------------------------------
   procedure Shortest_Path (
         Head : in     Headarray; 
         Map  : in     Maparray   ) is 

      type Distarray is array (0 .. 8) of Float; 
      Dist        : Distarray   := (others => 10000000.0); --path distance   
      Dmin        : Integer     := 0;                      --which path is shortest                           
      Dcalc       : Float       := 0.0;  
      Xcor,  
      Ycor        : Map_Range   := 100;  
      Instring    : Name_String;  
      Current_Ptr : Way_Ptr;  
      Yval,  
      Xval        : Float       := 0.0;  
   begin

      Enter_Data(Map, Xcor,Ycor,Instring);   --Get data to search on

      if Instring = "          " then
         Put("That is not a valid waypoint.");
      else
         for I in 1..8 loop
            Dist(I) := 0.0;
            Current_Ptr:=Head(I);
            while Current_Ptr /= null loop
               if Current_Ptr.Next /= null then   --add up the distances
                  Yval := Float((Current_Ptr.Next.Ycor - Current_Ptr.Ycor)**2);
                  Xval := Float((Current_Ptr.Next.Xcor - Current_Ptr.Xcor)**2);
                  Dcalc := Ada.Numerics.Elementary_Functions.Sqrt(Xval+
                     Yval);
                  Dist(I) := Dist(I) + Dcalc;

                  if Current_Ptr.Next.Xcor = Xcor and --if on the point then finish
                        Current_Ptr.Next.Ycor = Ycor then
                     if Dist(I) < Dist(Dmin) then  --save shortest distance and path
                        Dmin := I;
                     end if;
                     exit;
                  end if;
               end if;
               Current_Ptr:=Current_Ptr.Next;
            end loop;
         end loop;

         New_Line;      --display output
         if Dist(Dmin) = 10000000.0 then
            Put("That waypoint is the start point of the path.");
         else
            Put("The shortest path is: ");
            Ada.Integer_Text_Io.Put(Dmin,2);
            Put(", with a distance of: ");
            Ada.Float_Text_Io.Put(Dist(Dmin),4,2,0);
         end if;
      end if;

   end Shortest_Path;

   -----------------------------------------------------------------
   -- Given destination coord or the name of waypoint
   -- find the least dangerous path 
   --
   --            --------
   --  Map----->|        |
   --  Head---->| Safe   |
   --           | est    |
   --           | Path   |
   --            --------
   -----------------------------------------------------------------
   procedure Safest_Path (
         Head : in     Headarray; 
         Map  : in     Maparray   ) is 

      type Safearray is array (0 .. 8) of Threat_Code; 
      Safe        : Safearray   := (others => Green);  
      Smin        : Integer     := 0;                 --which path is safest                           
      Xcor,  
      Ycor        : Map_Range   := 100;  
      Instring    : Name_String;  
      Current_Ptr : Way_Ptr;  
      Tl          : Threat_Code;  

   begin

      Enter_Data(Map, Xcor,Ycor,Instring);

      if Instring = "          " then
         Put("That is not a valid waypoint.");
      else
         for I in 1..8 loop
            Current_Ptr:=Head(I);
            while Current_Ptr /= null loop --trace path and set safety level
               Tl := Map(Current_Ptr.Xcor,Current_Ptr.Ycor).Threat_Level;
               if Tl = Red or Tl = Unknown then
                  Safe(I) := Red;
               elsif Safe(I) /= Red and Tl = Amber then
                  Safe(I) := Amber;
               elsif Safe(I) /=Red and Safe(I) /=Amber then
                  Safe(I) := Green;
               end if;

               if Current_Ptr.Xcor = Xcor and Current_Ptr.Ycor = Ycor then
                  for J in 1..8 loop   --determine which path is safest
                     if Safe(I) = Green and (Safe(J) = Red or Safe(J) =
                           Amber) then
                        Smin :=I;
                     elsif Safe(I) = Amber and Safe(J) = Red then
                        Smin := I;
                     else
                        Smin := I;
                     end if;
                  end loop;
                  exit;
               end if;
               Current_Ptr:=Current_Ptr.Next;
            end loop;
         end loop;

         New_Line;      --display output
         Put("The safest path is: ");
         Ada.Integer_Text_Io.Put(Smin,1);
         Put(", with a threat level of: ");
         Threat_Code_Io.Put(Safe(Smin));
      end if;

   end Safest_Path;

   -----------------------------------------------------------------
   -- Add a point to an existing path at any location in the path
   --
   --
   --            --------
   --  Map----->|        |----> Map
   --  Head---->| Add    |----> Head
   --           | Way    |
   --           | Point  |
   --            --------
   -----------------------------------------------------------------
   procedure Add_Waypoint (
         Map  : in out Maparray; 
         Head : in out Headarray ) is 
      Current_Ptr : Way_Ptr;  
      Temp_Ptr    : Way_Ptr;  
      Instring    : Name_String;  
      subtype Path is Integer range 1..8;
      Add_Path : Path      := 1;  
      Inchar   : Character := 'n';  
   begin
      Temp_Ptr := new Waypoint;

      Skip_Line;
      Instring := Enter_Waypoint_Name;
      Temp_Ptr.Xcor := Get_A_Coord(1);
      Temp_Ptr.Ycor := Get_A_Coord(2);
      Map(Temp_Ptr.Xcor,Temp_Ptr.Ycor).Name:=Instring;
      Map(Temp_Ptr.Xcor,Temp_Ptr.Ycor).Threat_Level:=Enter_Threat_Code;

      loop
         begin
            New_Line;
            Put("Enter the path you want to put this waypoint on: ");
            Ada.Integer_Text_Io.Get(Add_Path);
            exit;
         exception
            when Constraint_Error | Data_Error =>
               Skip_Line;
               New_Line;
               Put_Line("ERROR: That input was no good. Use 1-8.");
         end;
      end loop;

      if Head(Add_Path) = null then
         Head(Add_Path) := Temp_Ptr;
      else
         Put("Do you want this point to be a new depot (y/n)? ");
         Get(Inchar);
         if Inchar = 'y' then               --add point at the head of list
            Temp_Ptr.Next := Head(Add_Path);
            Head(Add_Path) := Temp_Ptr;
         else
            Current_Ptr := Head(Add_Path);
            while Current_Ptr /= null loop       --ask user where to put point
               Put(Map(Current_Ptr.Xcor,Current_Ptr.Ycor).Name);
               Put("  =>  Do you want to add the point after this one (y/n)? ");
               Get(Inchar);
               if Inchar = 'y' or Current_Ptr.Next = null then
                  Temp_Ptr.Next := Current_Ptr.Next;  --add in temp_ptr
                  Current_Ptr.Next := Temp_Ptr;
                  exit;
               end if;
               Current_Ptr := Current_Ptr.Next; --traverse list
            end loop;
         end if;
      end if;

   end Add_Waypoint;

   -----------------------------------------------------------------
   -- Remove a point from an existing path
   --
   --
   --            --------
   --  Head---->|        |----> Head
   --  Map----->| Remove |----> Map
   --           | Way    |
   --           | Point  |
   --            --------
   -----------------------------------------------------------------
   procedure Remove_Waypoint (
         Head : in out Headarray; 
         Map  : in out Maparray   ) is 

      Xcor,                             --coordinate variables                                                        
      Ycor        : Map_Range   := 100;  
      I           : Integer     := 1;   --loop control variable                                                        
      Instring    : Name_String;        -- := (others => ' ');                                              
      Current_Ptr : Way_Ptr;  
      Last_Ptr    : Way_Ptr;  
      Erase       : Character   := 'n';  
   begin

      Enter_Data(Map, Xcor,Ycor,Instring);

      if Instring = "          " then
         Put("That is not a valid waypoint.");
      else

         Current_Ptr:=Head(I);            --look for waypoint in all the arrays
         while Current_Ptr /= null loop
            if Current_Ptr.Xcor = Xcor and Current_Ptr.Ycor = Ycor then
               Put("Do you want to remove this waypoint from path ");
               Ada.Integer_Text_Io.Put(I,1);
               Put(" (y/n)? ");
               Get(Erase);
               if Erase = 'y' then
                  if Current_Ptr.Next = null then   --erases last point in list
                     Dispose(Current_Ptr);
                     Current_Ptr := Last_Ptr;
                     Current_Ptr.Next := null;
                  elsif Current_Ptr = Head(I) and Head(I) /= null then
                     Head(I) := Head(I).Next;    --erases head of list
                  elsif Head(I).Next = null then
                     Dispose(Head(I));        --if there is only one point in list
                  else
                     Last_Ptr.Next := Current_Ptr.Next;  --point in middle of list
                     Dispose(Current_Ptr);
                     Current_Ptr := Last_Ptr.Next;
                  end if;
               end if;
            end if;
            if Current_Ptr.Next /= null then
               Last_Ptr := Current_Ptr;
               Current_Ptr :=Current_Ptr.Next;
            else
               I := I + 1;
               Current_Ptr:=Head(I);
            end if;
         end loop;
      end if;

   end Remove_Waypoint;

   -----------------------------------------------------------------
   -- Change threat code of an existing waypoint
   --
   --            --------
   --  Map----->|        |----> Map
   --  Head---->| Change |
   --           | Threat |
   --           | Code   |
   --            --------
   -----------------------------------------------------------------
   procedure Change_Threat_Code (
         Head : in     Headarray; 
         Map  : in out Maparray   ) is 

      Xcor     : Map_Range   := 100;  
      Ycor     : Map_Range   := 100;  
      Instring : Name_String := (others => ' ');  

   begin

      Enter_Data(Map, Xcor,Ycor,Instring);  --get users data 

      if Instring = "          " then
         Put("That is not a valid waypoint.");
      else                                  --get new threat code           
         Map(Xcor,Ycor).Threat_Level := Enter_Threat_Code;
      end if;

   end Change_Threat_Code;


   -----------------------------------------------------------------
   -- Print all paths
   --
   --            --------
   --  Map----->|        |
   --  Head---->| Print  |
   --           | Paths  |
   --           |        |
   --            --------
   -----------------------------------------------------------------
   procedure Print_Paths (
         Head : in     Headarray; 
         Map  : in     Maparray   ) is 

      Current_Ptr : Way_Ptr;  

   begin

      for I in 1..8 loop
         Current_Ptr:=Head(I);
         while Current_Ptr /= null loop   --loop for displaying
            New_Line(2);
            Put("Path number: " );
            Ada.Integer_Text_Io.Put(I,1);
            New_Line;
            Put("Name        X   Y    Threat");
            while Current_Ptr /= null loop      --display each path
               New_Line;
               Ada.Text_Io.Put(Map(Current_Ptr.Xcor,Current_Ptr.Ycor).
                  Name);
               Ada.Integer_Text_Io.Put(Current_Ptr.Xcor, 4);
               Ada.Integer_Text_Io.Put(Current_Ptr.Ycor,4 );
               Put("   ");
               Threat_Code_Io.Put(Map(Current_Ptr.Xcor,Current_Ptr.Ycor).
                  Threat_Level);
               Current_Ptr :=Current_Ptr.All.Next;
            end loop;
         end loop;
      end loop;

   end Print_Paths;

   -----------------------------------------------------------------
   -- Load a set of paths from paths.txt
   --
   --            --------
   --           |        |
   --           | Load   |-->Map
   --           | Paths  |-->Head
   --           |        |
   --            --------
   -----------------------------------------------------------------
   procedure Load_Paths (
         Head :    out Headarray; 
         Map  :    out Maparray   ) is 

      I           : Integer      := 0;  
      Path_File   : File_Type;  
      In_Control  : File_Control := Beginpath;  
      Instring    : Name_String;               --Name Input String From File                                                        
      Current_Ptr : Way_Ptr;                   --first pointer                

   begin

      Head := (others => null);
      Open(Path_File, In_File, "paths.txt");
      Get(Path_File,In_Control);

      while not End_Of_File(Path_File) loop  --read file until it is empty
         case In_Control is                 --case for each file control
            when Beginpath =>
               I := I + 1;
               if I = 9 then
                  exit;
               end if;
               Head(I) := new Waypoint;
               Current_Ptr := new Waypoint;
            when Beginpoint =>              --add stuff to linked list
               if Current_Ptr.Next = null then
                  Current_Ptr.All.Next := new Waypoint;
                  Current_Ptr := Current_Ptr.All.Next;
               end if;
               Get(Path_File,Instring); --get name and save for map
               Ada.Integer_Text_Io.Get(Path_File,Current_Ptr.All.Xcor);
               Ada.Integer_Text_Io.Get(Path_File,Current_Ptr.All.Ycor);
               Map(Current_Ptr.Xcor,Current_Ptr.All.Ycor).Name := Instring;
               Threat_Code_Io.Get(Path_File,Map(Current_Ptr.All.Xcor,
                     Current_Ptr.All.Ycor).Threat_Level);
               if Head(I).Next = null then
                  Head(I) := Current_Ptr;
               end if;
            when Endpoint =>
               null;
            when Endpath =>
               null;
            when others =>
               Put("Incorrect Input");
         end case;
         Get(Path_File,In_Control);
      end loop;
      Close(Path_File);
   exception       --exception handling for file
      when Name_Error =>
         New_Line;
         Put ("ERROR: Input file for paths does not exist.");
      when End_Error | Data_Error =>
         New_Line;
         Put("ERROR: Data file no good.");

   end Load_Paths;

   -----------------------------------------------------------------
   -- Save current paths to paths.txt
   --
   --            --------
   --  Head---->|        |
   --  Map----->| Save   |-->paths.txt
   --           | Paths  |
   --           |        |
   --            --------
   -----------------------------------------------------------------
   procedure Save_Paths (
         Head : in     Headarray; 
         Map  : in     Maparray   ) is 

      Path_File   : File_Type;  
      Current_Ptr : Way_Ptr;  

   begin

      Open(Path_File,Out_File,"paths.txt");
      for I in 1..8 loop     --loop for each path
         Current_Ptr := Head(I);
         while Current_Ptr /=null loop
            Ada.Text_Io.Put_Line(Path_File,"BEGINPATH");
            while Current_Ptr /= null loop
               Ada.Text_Io.Put_Line(Path_File,"BEGINPOINT");
               Ada.Text_Io.Put_Line(Path_File,Map(Current_Ptr.Xcor,
                     Current_Ptr.Ycor).Name);
               Ada.Integer_Text_Io.Put(Path_File,Current_Ptr.Xcor,3);
               New_Line(Path_File);
               Ada.Integer_Text_Io.Put(Path_File,Current_Ptr.Ycor,3);
               New_Line(Path_File);
               Threat_Code_Io.Put(Path_File,Map(Current_Ptr.Xcor,
                     Current_Ptr.Ycor).Threat_Level);
               New_Line(Path_File);
               Ada.Text_Io.Put_Line(Path_File,"ENDPOINT");
               Current_Ptr := Current_Ptr.Next;
            end loop;
            Ada.Text_Io.Put_Line(Path_File,"ENDPATH");
         end loop;
      end loop;
      Close(Path_File);

   end Save_Paths;


begin

   null;

end Waypoints;
