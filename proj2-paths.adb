-- File name    : proj2.adb
-- Purpose      : Project 2 Final Submission
-- Author       : erl
-- Course       : CS301
-- Hour/section : G4

with Ada.Text_Io, Ada.Integer_Text_Io, Waypoints;
use  Ada.Text_Io, Ada.Integer_Text_Io;
use Waypoints;

procedure Proj2 is 

   subtype Menu_Choices is Integer range 1..10;
   Menu_Choice : Menu_Choices := 1;  

   function Menu return Menu_Choices is 
      Choice : Menu_Choices := 1;  
   begin
      loop
         begin
            New_Line(2);
            Put_Line("What do you want to do?");
            Put_Line("   1. Create a new path.");
            Put_Line("   2. Print all paths.");
            Put_Line("   3. Load a set of paths from paths.txt.");
            Put_Line("   4. Save the data to paths.txt.");
            Put_Line("   5. Delete a waypoint.");
            Put_Line("   6. Add a waypoint.");
            Put_Line("   7. Change the threat code of a waypoint.");
            Put_Line("   8. Find the shortest path to a waypoint.");
            Put_Line("   9. Find the safest path to a waypoint.");
            Put_Line("   10. Exit this program.");
            New_Line;
            Put("Enter your choice: ");
            Get(Choice);
            exit;
         exception
            when Constraint_Error =>
               New_Line;
               Put_Line("That choice was no good. Try again.");
            when Data_Error=>
               Skip_Line;
               New_Line;
               Put_Line("That choice was no good. Try again.");
         end;
      end loop;
      New_Line;
      return Choice;
   end Menu;

begin

   while Menu_Choice /= 10 loop

      Menu_Choice:= Menu;

      case Menu_Choice is
         when 1 =>
            Create_New_Path(Head,Map);
         when 2 =>
            Print_Paths(Head,Map);
         when 3 =>
            Load_Paths(Head,Map);
         when 4 =>
            Save_Paths(Head,Map);
         when 5 =>
            Remove_Waypoint(Head,Map);
         when 6 =>
            Add_Waypoint(Map,Head);
         when 7 =>
            Change_Threat_Code(Head,Map);
         when 8 =>
            Shortest_Path(Head,Map);
         when 9 =>
            Safest_Path(Head,Map);
         when 10 =>
            null;
      end case;
   end loop;

end Proj2;


