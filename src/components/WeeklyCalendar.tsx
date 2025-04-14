import React, { useState, useEffect, useRef } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { Shift, selectShift, clearShift, moveEmployeeBetweenShifts } from '../store/shiftsSlice';
import CustomShiftModal from './CustomShiftModal';

interface WeeklyCalendarProps {
  useAiSuggestions?: boolean;
}

const WeeklyCalendar: React.FC<WeeklyCalendarProps> = ({ useAiSuggestions = false }) => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const shifts = useSelector((state: RootState) => 
    useAiSuggestions ? state.shifts.aiSuggestions || [] : state.shifts.shifts
  );
  const employees = useSelector((state: RootState) => state.shifts.employees);
  
  // State to track drag operations
  const [isDragging, setIsDragging] = useState(false);
  const [draggedShiftId, setDraggedShiftId] = useState<string | null>(null);
  const [dragAction, setDragAction] = useState<'move' | 'swap' | null>(null);
  
  // State for custom shift modal
  const [isCustomShiftModalOpen, setIsCustomShiftModalOpen] = useState(false);
  
  // Get unique days and time slots
  const days = Array.from(new Set(shifts.map((shift: Shift) => shift.day))) as string[];
  const [timeSlots, setTimeSlots] = useState<string[]>(
    Array.from(new Set(shifts.map((shift: Shift) => shift.timeSlot))) as string[]
  );
  
  // State for add time slot popup
  const [showAddTimeSlotPopup, setShowAddTimeSlotPopup] = useState(false);
  const [newStartTime, setNewStartTime] = useState('');
  const [newEndTime, setNewEndTime] = useState('');
  const popupRef = useRef<HTMLDivElement>(null);
  
  const handleShiftClick = (shift: Shift) => {
    dispatch(selectShift(shift));
  };
  
  const handleClearShift = (e: React.MouseEvent, shiftId: string) => {
    e.stopPropagation();
    dispatch(clearShift(shiftId));
  };
  
  // Drag and drop handlers
  const handleDragStart = (e: React.DragEvent<HTMLDivElement>, shiftId: string) => {
    if (useAiSuggestions || !e.currentTarget.classList.contains('shift-card-assigned')) return;
    
    setIsDragging(true);
    setDraggedShiftId(shiftId);
    e.dataTransfer.setData('text/plain', shiftId);
    e.dataTransfer.effectAllowed = 'move';
    
    // Add dragstart styling
    const dragImage = e.currentTarget.cloneNode(true) as HTMLDivElement;
    dragImage.style.width = `${e.currentTarget.offsetWidth}px`;
    dragImage.style.opacity = '0.5';
    
    document.body.appendChild(dragImage);
    e.dataTransfer.setDragImage(dragImage, 0, 0);
    setTimeout(() => {
      document.body.removeChild(dragImage);
    }, 0);
  };
  
  const handleDragOver = (e: React.DragEvent<HTMLDivElement>, targetShiftId: string) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    e.currentTarget.classList.add('drag-over');
    
    // Determine if this is a move or swap operation
    if (draggedShiftId) {
      const sourceShift = shifts.find((s: Shift) => s.id === draggedShiftId);
      const targetShift = shifts.find((s: Shift) => s.id === targetShiftId);
      
      if (sourceShift && targetShift && targetShift.employeeId) {
        setDragAction('swap');
        e.currentTarget.classList.add('swap-target');
      } else {
        setDragAction('move');
        e.currentTarget.classList.remove('swap-target');
      }
    }
  };
  
  const handleDragLeave = (e: React.DragEvent<HTMLDivElement>) => {
    e.currentTarget.classList.remove('drag-over');
    e.currentTarget.classList.remove('swap-target');
  };
  
  const handleDrop = (e: React.DragEvent<HTMLDivElement>, targetShiftId: string) => {
    e.preventDefault();
    e.currentTarget.classList.remove('drag-over');
    
    const sourceShiftId = e.dataTransfer.getData('text/plain');
    
    if (sourceShiftId && sourceShiftId !== targetShiftId && draggedShiftId) {
      dispatch(moveEmployeeBetweenShifts({ sourceShiftId, targetShiftId }));
    }
    
    setIsDragging(false);
    setDraggedShiftId(null);
  };
  
  const handleDragEnd = () => {
    setIsDragging(false);
    setDraggedShiftId(null);
    setDragAction(null);
    
    // Remove drag-over class from all cells
    const cells = document.querySelectorAll('.drag-over, .swap-target');
    cells.forEach(cell => {
      cell.classList.remove('drag-over');
      cell.classList.remove('swap-target');
    });
  };
  
  const getEmployeeName = (employeeId: string | null) => {
    if (!employeeId) return null;
    const employee = employees.find((emp: { id: string }) => emp.id === employeeId);
    return employee ? employee.name : null;
  };
  
  const handleAddCustomShift = (customShift: any) => {
    // TODO: Implement logic to add custom shift to the schedule
    console.log('Adding custom shift:', customShift);
  };
  
  // Close popup when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (popupRef.current && !popupRef.current.contains(event.target as Node)) {
        setShowAddTimeSlotPopup(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  return (
    <>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="p-2 text-sm bg-gray-100 text-center text-gray-700 min-h-[32px] transition-opacity duration-200" 
          style={{ opacity: isDragging ? 1 : 0 }}>
          {isDragging && (
            dragAction === 'swap' ? 
              t('dragDrop.swapEmployees') : 
              t('dragDrop.moveEmployee')
          )}
        </div>
        <div className="grid grid-cols-8 border-b">
          <div className="p-3 font-medium text-gray-500 border-r flex items-center justify-between">
            <span>{t('common.timeSlot')}</span>
            <button 
              onClick={(e) => {
                e.stopPropagation();
                setShowAddTimeSlotPopup(true);
              }}
              className="ml-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-full w-6 h-6 flex items-center justify-center focus:outline-none"
              title="Add new time slot"
            >
              +
            </button>
            
            {/* Popup for adding new time slot */}
            {showAddTimeSlotPopup && (
              <div 
                ref={popupRef}
                className="absolute z-50 bg-white shadow-lg rounded-md p-4 border border-gray-200"
                style={{ top: '60px', left: '20px', width: '300px' }}
              >
                <div className="flex justify-between items-center mb-3">
                  <h3 className="font-medium">Add New Time Slot</h3>
                  <button
                    onClick={() => setShowAddTimeSlotPopup(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    ×
                  </button>
                </div>
                
                <div className="grid grid-cols-2 gap-3 mb-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Start Time</label>
                    <input 
                      type="time"
                      value={newStartTime}
                      onChange={(e) => setNewStartTime(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">End Time</label>
                    <input 
                      type="time"
                      value={newEndTime}
                      onChange={(e) => setNewEndTime(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md"
                    />
                  </div>
                </div>
                
                <div className="flex justify-end">
                  <button
                    onClick={() => {
                      if (newStartTime && newEndTime) {
                        const newTimeSlot = `${newStartTime}-${newEndTime}`;
                        // Add the new time slot if it doesn't already exist
                        if (!timeSlots.includes(newTimeSlot)) {
                          setTimeSlots(prev => [...prev, newTimeSlot].sort());
                        }
                        setNewStartTime('');
                        setNewEndTime('');
                        setShowAddTimeSlotPopup(false);
                      }
                    }}
                    className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
                  >
                    Add
                  </button>
                </div>
              </div>
            )}
          </div>
          {days.map((day) => (
            <div key={day} className="p-3 font-medium text-center text-gray-800 border-r">
              {t(`days.${day.toLowerCase()}`)}
            </div>
          ))}
        </div>
        
        {timeSlots.map((timeSlot) => (
          <div key={timeSlot} className="grid grid-cols-8 border-b">
            <div className="p-3 font-medium text-gray-500 border-r flex items-center">
              {timeSlot}
            </div>
            
            {days.map((day) => {
              const shift = shifts.find((s: Shift) => s.day === day && s.timeSlot === timeSlot);
              const hasEmployee = shift?.employeeId !== null;
              
              return (
                <div
                  key={`${day}-${timeSlot}`}
                  className={`p-1 border-r h-24 ${useAiSuggestions ? 'cursor-default' : 'cursor-pointer'} ${isDragging ? 'droppable-cell' : ''}`}
                  onClick={() => !useAiSuggestions && shift && handleShiftClick(shift)}
                  onDragOver={!useAiSuggestions ? (e) => shift && handleDragOver(e, shift.id) : undefined}
                  onDragLeave={!useAiSuggestions ? (e) => handleDragLeave(e) : undefined}
                  onDrop={!useAiSuggestions ? (e) => shift && handleDrop(e, shift.id) : undefined}
                >
                  <div 
                    className={`shift-card ${hasEmployee ? 'shift-card-assigned' : 'shift-card-empty'}`}
                    draggable={!useAiSuggestions && hasEmployee}
                    onDragStart={!useAiSuggestions && hasEmployee ? (e) => shift && handleDragStart(e, shift.id) : undefined}
                    onDragEnd={!useAiSuggestions ? handleDragEnd : undefined}
                  >
                    {shift?.employeeId ? (
                      <div className="h-full flex flex-col">
                        <div className="flex justify-between items-start">
                          <span className="font-medium">{getEmployeeName(shift.employeeId)}</span>
                          {!useAiSuggestions && (
                            <button
                              onClick={(e) => handleClearShift(e, shift.id)}
                              className="text-gray-400 hover:text-gray-600"
                            >
                              ×
                            </button>
                          )}
                        </div>
                        {shift.role && (
                          <span className="mt-1 text-gray-600 text-xs">{shift.role}</span>
                        )}
                      </div>
                    ) : (
                      <div className="flex items-center justify-center h-full text-gray-400">
                        + {t('common.add')}
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        ))}
      </div>
      
      <CustomShiftModal 
        isOpen={isCustomShiftModalOpen}
        onClose={() => setIsCustomShiftModalOpen(false)}
        onAddShift={handleAddCustomShift}
      />
    </>
  );
};

export default WeeklyCalendar;
