import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { deleteEmployee } from '../store/employeesSlice';

interface DeleteEmployeeModalProps {
  isOpen: boolean;
  onClose: () => void;
  employeeId: string | null;
}

const DeleteEmployeeModal: React.FC<DeleteEmployeeModalProps> = ({ 
  isOpen, 
  onClose, 
  employeeId 
}) => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const selectedEmployee = useSelector((state: RootState) => 
    state.employees.employees.find(emp => emp.id === employeeId)
  );

  const handleDelete = async () => {
    if (employeeId) {
      await dispatch(deleteEmployee(employeeId));
      onClose();
    }
  };

  if (!isOpen || !selectedEmployee) return null;

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 overflow-y-auto"
      aria-modal="true"
      role="dialog"
    >
      <div className="relative w-full max-w-md p-4 mx-auto bg-white rounded-lg shadow-xl">
        <div className="p-6 text-center">
          <svg 
            className="w-16 h-16 mx-auto mb-4 text-red-500" 
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24" 
            xmlns="http://www.w3.org/2000/svg"
          >
            <path 
              strokeLinecap="round" 
              strokeLinejoin="round" 
              strokeWidth={2} 
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" 
            />
          </svg>
          
          <h3 className="mb-5 text-lg font-normal text-gray-500">
            {t('employees.deleteConfirmation', { 
              name: selectedEmployee.name 
            })}
          </h3>
          
          <div className="flex justify-center space-x-4">
            <button
              type="button"
              onClick={handleDelete}
              className="text-white bg-red-600 hover:bg-red-800 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm inline-flex items-center px-5 py-2.5 text-center"
            >
              {t('common.delete')}
            </button>
            
            <button
              type="button"
              onClick={onClose}
              className="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-gray-200 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10"
            >
              {t('common.cancel')}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DeleteEmployeeModal;
