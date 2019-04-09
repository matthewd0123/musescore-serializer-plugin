//=============================================================================
//  MuseScore
//  Linux Music Score Editor
//  $Id:$
//
//  Melody Serializer
//  Matthew D'Alonzo
//  Madalyn Schulte
//  Dan Wilborn

//  ADAPTED FROM:
//  Color Half Steps (Sharps & Flats) plugin
//
//  Copyright (C)2011 Mike Magatagan
//  Modified for MuseScore 2.0 by Chad Kurszewski
//  Modified for MuseScore 3.0 by Joachim Schmitz
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//=============================================================================

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
      version:  "3.0"
      description: "This plugin will take your notes and turn them into tone rows."
      menuPath: "Plugins.Notes.Serializer"

      property variant black : "#000000"
	  property variant red : "#ff0000"


      // Apply the given function to all notes in selection
      // or, if nothing is selected, in the entire score

      function applyToNotesInSelection(func) {
            var cursor = curScore.newCursor();
            cursor.rewind(1);
            var startStaff;
            var endStaff;
            var endTick;
            var fullScore = false;
            if (!cursor.segment) { // no selection
                  fullScore = true;
                  startStaff = 0; // start with 1st staff
                  endStaff = curScore.nstaves - 1; // and end with last
            } else {
                  startStaff = cursor.staffIdx;
                  cursor.rewind(2);
                  if (cursor.tick == 0) {
                        // this happens when the selection includes
                        // the last measure of the score.
                        // rewind(2) goes behind the last segment (where
                        // there's none) and sets tick=0
                        endTick = curScore.lastSegment.tick + 1;
                  } else {
                        endTick = cursor.tick;
                  }
                  endStaff = cursor.staffIdx;
            }
            console.log(startStaff + " - " + endStaff + " - " + endTick)
            for (var staff = startStaff; staff <= endStaff; staff++) {
                  for (var voice = 0; voice < 4; voice++) {
                        cursor.rewind(1); // sets voice to 0
                        cursor.voice = voice; //voice has to be set after goTo
                        cursor.staffIdx = staff;

                        if (fullScore)
                              cursor.rewind(0) // if no selection, beginning of score

                        var note_list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
                        var tone_row = [];
                        var tone_counter = 0;
                        while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                              if (cursor.element && cursor.element.type == Element.CHORD) {
                                    var notes = cursor.element.notes;
                                    for (var i = 0; i < notes.length; i++) {
                                          var note = notes[i];
                                          if  (note_list.length > 0){
                                            if (note_list.includes(note.pitch%12)){
                                              for (var j = 0; j < note_list.length; j++){
                                                if (note_list[j]  == note.pitch%12){
                                                  tone_row.push(note_list[j])
                                                  note_list.splice(j, 1);
                                                  break;
                                                }
                                              }
                                            }else{
                                                  var modded_note = notes[i].pitch%12;
                                                  var closest_note = note_list[0];
                                                  for (var k = 1; k < note_list.length; k++){
                                                    if (Math.abs(modded_note-note_list[k]) < Math.abs(modded_note - closest_note)){
                                                       closest_note = note_list[k];
                                                    }
                                                  }
                                                  tone_row.push(closest_note);
                                                  var octave = Math.floor(notes[i].pitch/12);
                                                  notes[i].pitch = closest_note+12*octave;
                                                  switch (closest_note){
                                                    case 9:
                                                      notes[i].tpc = 17;
                                                      break;
                                                    case 10:
                                                      notes[i].tpc = 12;
                                                      break;
                                                    case 11:
                                                      notes[i].tpc = 19;
                                                      break;
                                                    case 0:
                                                      notes[i].tpc = 14;
                                                      break;
                                                    case  1:
                                                      notes[i].tpc = 9;
                                                      break;
                                                    case 2:
                                                       notes[i].tpc = 16;
                                                       break;
                                                     case 3:
                                                       notes[i].tpc = 11;
                                                       break;
                                                     case 4:
                                                       notes[i].tpc = 18;
                                                       break;
                                                     case 5:
                                                       notes[i].tpc = 13;
                                                       break;
                                                     case 6:
                                                       notes[i].tpc = 8;
                                                       break;
                                                     case 7:
                                                       notes[i].tpc = 15;
                                                       break;
                                                     case 8:
                                                       notes[i].tpc = 10;
                                                       break;
                                                  }
                                                  for (var j = 0; j < note_list.length; j++){
                                                    if (note_list[j]  == closest_note){
                                                      note_list.splice(j, 1);
                                                      break;
                                                    }
                                                  }
                                            }
                                          }else{
                                            var octave = Math.floor(notes[i].pitch/12);
                                            notes[i].pitch = tone_row[tone_counter] + 12*octave;
                                            switch (tone_row[tone_counter]){
                                              case 9:
                                                notes[i].tpc = 17;
                                                break;
                                              case 10:
                                                notes[i].tpc = 12;
                                                break;
                                              case 11:
                                                notes[i].tpc = 19;
                                                break;
                                              case 0:
                                                notes[i].tpc = 14;
                                                break;
                                              case  1:
                                                notes[i].tpc = 9;
                                                break;
                                              case 2:
                                                 notes[i].tpc = 16;
                                                 break;
                                               case 3:
                                                 notes[i].tpc = 11;
                                                 break;
                                               case 4:
                                                 notes[i].tpc = 18;
                                                 break;
                                               case 5:
                                                 notes[i].tpc = 13;
                                                 break;
                                               case 6:
                                                 notes[i].tpc = 8;
                                                 break;
                                               case 7:
                                                 notes[i].tpc = 15;
                                                 break;
                                               case 8:
                                                 notes[i].tpc = 10;
                                                 break;
                                            }
                                            tone_counter= (tone_counter+1)%12;
                                          }
                                    }
                              }
                              cursor.next();
                        }
                  }
            }
      }

      onRun: {
            console.log("Serializer");

            if (typeof curScore === 'undefined')
                  Qt.quit();

            applyToNotesInSelection()

            Qt.quit();
         }
}
