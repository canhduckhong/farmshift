import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { assignShift, closeModal, mockRoles } from '../store/shiftsSlice';

const AssignShiftModal: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const selectedShift = useSelector((state: RootState) => state.shifts.selectedShift);
  const employees = useSelector((state: RootState) => state.shifts.employees);
  
  const [employeeId, setEmployeeId] = useState<string>('');
  const [role, setRole] = useState<string | null>(null);
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (employeeId) {
      dispatch(assignShift({ employeeId, role }));
    }
  };
  
  const handleCancel = () => {
    dispatch(closeModal());
  };
  
  if (!selectedShift) return null;
  
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
        <h2 className="text-xl font-bold mb-4">
          {t('shiftAssignment.assignTo')} {t(`days.${selectedShift.day.toLowerCase()}`)}, {t(`timeSlots.${selectedShift.timeSlot.toLowerCase()}`)}
        </h2>
        
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label htmlFor="employee" className="block text-sm font-medium text-gray-700 mb-1">
              {t('shiftAssignment.assignEmployee')}
            </label>
            <select
              id="employee"
              className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
              value={employeeId}
              onChange={(e) => setEmployeeId(e.target.value)}
              required
            >
              <option value="">{t('shiftAssignment.selectEmployee')}</option>
              {employees.map((employee: { id: string; name: string; role: string }) => (
                <option key={employee.id} value={employee.id}>
                  {employee.name} ({employee.role})
                </option>
              ))}
            </select>
          </div>
          
          <div className="mb-6">
            <label htmlFor="role" className="block text-sm font-medium text-gray-700 mb-1">
              {t('shiftAssignment.role')} (Optional)
            </label>
            <select
              id="role"
              className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
              value={role || ''}
              onChange={(e) => setRole(e.target.value || null)}
            >
              <option value="">{t('shiftAssignment.selectRole')}</option>
              {mockRoles.map(taskRole => (
                <option key={taskRole} value={taskRole}>
                  {taskRole}
                </option>
              ))}
            </select>
          </div>
          
          <div className="flex justify-end space-x-2">
            <button
              type="button"
              className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              onClick={handleCancel}
            >
              {t('common.close')}
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-primary-600 border border-transparent rounded-md text-sm font-medium text-white hover:bg-primary-700"
              disabled={!employeeId}
            >
              {t('shiftAssignment.assignEmployee')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AssignShiftModal;
