<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\Tutor;
class TutorSeeder extends Seeder
{
    public function run()
    {
        // Safe delete
        foreach (Tutor::all() as $t) {
            $t->delete();
        }

        Tutor::create([
            'name' => 'Nguyễn Văn Hùng',
            'avatar_url' => 'https://i.pravatar.cc/150?u=1',
            'bio' => 'GV Toán, 10 năm kinh nghiệm dạy chuyên.',
            'hourly_rate' => 200000,
            'rating' => 4.8,
            'review_count' => 120,
            'location' => 'Hà Nội',
            'address' => 'Cầu Giấy',
            'is_verified' => true,
            'subjects' => ['Toán', 'Lý'],
            'teaching_mode' => ['Online', 'Offline'],
            'weekly_schedule' => ['2' => ['08:00 - 10:00']]
        ]);

        Tutor::create([
            'name' => 'Trần Thị Mai',
            'avatar_url' => 'https://i.pravatar.cc/150?u=2',
            'bio' => 'SV Ngoại Ngữ, IELTS 8.0.',
            'hourly_rate' => 150000,
            'rating' => 4.5,
            'review_count' => 45,
            'location' => 'Hồ Chí Minh',
            'subjects' => ['Anh', 'Văn'],
            'teaching_mode' => ['Online'],
            'weekly_schedule' => ['3' => ['18:00 - 20:00']]
        ]);

        Tutor::create([
            'name' => 'Lê Văn Cường',
            'avatar_url' => 'https://i.pravatar.cc/150?u=3',
            'bio' => 'GV Hóa Học, ôn thi đại học.',
            'hourly_rate' => 180000,
            'rating' => 4.7,
            'location' => 'Đà Nẵng',
            'subjects' => ['Hóa', 'Sinh'],
            'teaching_mode' => ['Offline']
        ]);

        Tutor::create([
            'name' => 'Phạm Thu Hà',
            'avatar_url' => 'https://i.pravatar.cc/150?u=4',
            'bio' => 'Giáo viên Piano tại nhạc viện.',
            'hourly_rate' => 300000,
            'rating' => 5.0,
            'location' => 'Hà Nội',
            'subjects' => ['Piano', 'Nhạc Lý'],
            'teaching_mode' => ['Offline']
        ]);

        for ($i = 5; $i <= 10; $i++) {
            Tutor::create([
                'name' => "Gia sư Dự Kết $i",
                'avatar_url' => "https://i.pravatar.cc/150?u=$i",
                'bio' => 'Gia sư nhiệt tình.',
                'hourly_rate' => 100000,
                'rating' => 4.0,
                'location' => 'Online',
                'subjects' => ['Toán'],
                'teaching_mode' => ['Online']
            ]);
        }
    }
}
