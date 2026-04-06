import React, { useState, useEffect } from 'react';
import { App, Tabs } from 'antd';
import { ClockCircleOutlined, HistoryOutlined, DollarOutlined } from '@ant-design/icons';
import { walletApi } from '../api/walletApi';
import WithdrawalTable from '../components/WithdrawalTable';
import PageHeader from '@/components/PageHeader';
import SectionCard from '@/components/SectionCard';

const WithdrawalPage = () => {
    const { message } = App.useApp(); 

    const [pendingList, setPendingList] = useState([]);
    const [historyList, setHistoryList] = useState([]);
    const [loading, setLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('1');

    const loadData = async (tabKey) => {
        setLoading(true);
        try {
            if (tabKey === '1') {
                const res = await walletApi.getPendingWithdrawals();
                setPendingList(res.data?.items || []);
            } else {
                const res = await walletApi.getProcessedWithdrawals();
                setHistoryList(res.data?.items || []);
            }
        } catch (error) {
            message.error("Không thể tải danh sách rút tiền.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadData(activeTab);
    }, [activeTab]);

    const handleApprove = async (id, receiptImageUrl) => {
        try {
            await walletApi.approveWithdrawal(id, { receiptImageUrl: String(receiptImageUrl) });
            message.success("Đã duyệt lệnh rút tiền và lưu biên lai thành công!");
            loadData('1'); 
        } catch (error) {
            message.error(error.response?.data?.message || "Lỗi dữ liệu, Backend không chấp nhận ảnh này.");
        }
    };

    const handleReject = async (id, adminNote) => {
        try {
            await walletApi.rejectWithdrawal(id, { adminNote: String(adminNote) });
            message.success("Đã từ chối và hoàn tiền thành công!");
            loadData('1'); 
        } catch (error) {
            message.error(error.response?.data?.message || "Lỗi khi từ chối lệnh.");
        }
    };

    const tabItems = [
        {
            key: '1',
            label: <span style={{ fontWeight: 500, padding: '0 8px' }}><ClockCircleOutlined />Chờ xử lý</span>,
            children: (
                <WithdrawalTable 
                    dataSource={pendingList} 
                    loading={loading} 
                    onApprove={handleApprove} 
                    onReject={handleReject} 
                    isHistoryTab={false} 
                />
            )
        },
        {
            key: '2',
            label: <span style={{ fontWeight: 500, padding: '0 8px' }}><HistoryOutlined />Lịch sử xử lý</span>,
            children: (
                <WithdrawalTable 
                    dataSource={historyList} 
                    loading={loading} 
                    isHistoryTab={true} 
                />
            )
        }
    ];

    return (
        <div style={{ padding: '24px', backgroundColor: '#F4F7FE', minHeight: '100vh' }}>
            <PageHeader title="Quản lý Rút tiền cửa hàng" />
            <SectionCard title="Yêu cầu rút tiền" icon={<DollarOutlined />} titleColor="#2B3674">
                <Tabs 
                    activeKey={activeTab} 
                    onChange={(key) => setActiveTab(key)} 
                    items={tabItems} 
                    size="large"
                    tabBarStyle={{ marginBottom: '24px' }}
                />
            </SectionCard>
        </div>
    );
};

export default WithdrawalPage;